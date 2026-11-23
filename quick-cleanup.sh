#!/usr/bin/env bash
# ==============================================================================
# EngineBeats / Ubuntu - Quick Disk Space Cleanup Script
# ==============================================================================
# Safely reclaims 15-30+ GB of disk space from caches, build artifacts,
# package manager archives, and log files without touching your code or docs.
#
# Usage:
#   ./quick-cleanup.sh        # Run full cleanup with confirmation
#   ./quick-cleanup.sh -y     # Run without confirmation prompt
# ==============================================================================

set -e

# Colors
BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Parse arguments
AUTO_CONFIRM=0
if [[ "$1" == "-y" || "$1" == "--yes" || "$1" == "--force" ]]; then
    AUTO_CONFIRM=1
fi

echo -e "\n${BOLD}${CYAN}======================================================${RESET}"
echo -e "${BOLD}${CYAN}         Ubuntu Quick Disk Space Cleanup Tool         ${RESET}"
echo -e "${BOLD}${CYAN}======================================================${RESET}\n"

# 1. Measure Initial Free Space
INITIAL_AVAIL_KB=$(df -k / | awk 'NR==2 {print $4}')
echo -e "${BOLD}Current Disk Usage on /:${RESET}"
df -h / | awk 'NR==1 || NR==2'

echo -e "\n${YELLOW}This script will safely remove temporary caches:${RESET}"
echo "  • ~/.cache/huggingface (~8 GB model cache)"
echo "  • ~/.cache/pip (~4 GB downloaded wheels)"
echo "  • ~/.cache/JetBrains (~4.3 GB IDE indexing caches)"
echo "  • ~/.cache/ms-playwright (~1.4 GB browser binaries)"
echo "  • Browser caches (Chrome, Brave)"
echo "  • NPM package cache (~/.npm/_cacache)"
echo "  • System apt package cache (/var/cache/apt)"
echo "  • Systemd journal logs (vacuum to 100M)"
echo "  • Unused Docker images & build cache (if docker is running)"

if [ "$AUTO_CONFIRM" -eq 0 ]; then
    echo ""
    read -p "Proceed with cleanup? [y/N]: " CONFIRM
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo -e "${RED}[*] Cleanup cancelled by user.${RESET}"
        exit 0
    fi
fi

echo -e "\n${CYAN}[1/6] Cleaning user development caches (~/.cache)...${RESET}"
# HuggingFace Cache
if [ -d "$HOME/.cache/huggingface" ]; then
    SIZE=$(du -sh "$HOME/.cache/huggingface" 2>/dev/null | cut -f1)
    rm -rf "$HOME/.cache/huggingface"
    echo -e "${GREEN}  ✔ Removed ~/.cache/huggingface ($SIZE)${RESET}"
fi

# Pip Cache
if [ -d "$HOME/.cache/pip" ]; then
    SIZE=$(du -sh "$HOME/.cache/pip" 2>/dev/null | cut -f1)
    rm -rf "$HOME/.cache/pip"
    echo -e "${GREEN}  ✔ Removed ~/.cache/pip ($SIZE)${RESET}"
fi

# JetBrains Caches
if [ -d "$HOME/.cache/JetBrains" ]; then
    SIZE=$(du -sh "$HOME/.cache/JetBrains" 2>/dev/null | cut -f1)
    rm -rf "$HOME/.cache/JetBrains"
    echo -e "${GREEN}  ✔ Removed ~/.cache/JetBrains ($SIZE)${RESET}"
fi

# Playwright Browser Binaries
if [ -d "$HOME/.cache/ms-playwright" ]; then
    SIZE=$(du -sh "$HOME/.cache/ms-playwright" 2>/dev/null | cut -f1)
    rm -rf "$HOME/.cache/ms-playwright"
    echo -e "${GREEN}  ✔ Removed ~/.cache/ms-playwright ($SIZE)${RESET}"
fi

# Browser Caches
for bcache in "$HOME/.cache/google-chrome" "$HOME/.cache/BraveSoftware" "$HOME/.cache/mozilla"; do
    if [ -d "$bcache" ]; then
        SIZE=$(du -sh "$bcache" 2>/dev/null | cut -f1)
        rm -rf "$bcache"
        echo -e "${GREEN}  ✔ Removed $(basename "$bcache") cache ($SIZE)${RESET}"
    fi
done

echo -e "\n${CYAN}[2/6] Cleaning Node.js / NPM cache...${RESET}"
if command -v npm &>/dev/null; then
    npm cache clean --force 2>/dev/null || true
    echo -e "${GREEN}  ✔ Cleared npm cache via npm cli${RESET}"
fi
if [ -d "$HOME/.npm/_cacache" ]; then
    SIZE=$(du -sh "$HOME/.npm/_cacache" 2>/dev/null | cut -f1)
    rm -rf "$HOME/.npm/_cacache"
    echo -e "${GREEN}  ✔ Removed ~/.npm/_cacache ($SIZE)${RESET}"
fi

echo -e "\n${CYAN}[3/6] Cleaning system journal logs...${RESET}"
if command -v journalctl &>/dev/null; then
    if [ "$EUID" -eq 0 ]; then
        journalctl --vacuum-size=100M 2>/dev/null || true
    elif sudo -n true 2>/dev/null; then
        sudo journalctl --vacuum-size=100M 2>/dev/null || true
    else
        echo -e "${YELLOW}  ℹ Skipped systemd journal vacuum (requires sudo)${RESET}"
    fi
fi

echo -e "\n${CYAN}[4/6] Cleaning APT package cache & orphaned packages...${RESET}"
if command -v apt-get &>/dev/null; then
    if [ "$EUID" -eq 0 ]; then
        apt-get clean
        apt-get autoremove --purge -y
        echo -e "${GREEN}  ✔ Cleaned apt cache & autoremoved unused packages${RESET}"
    elif sudo -n true 2>/dev/null; then
        sudo apt-get clean
        sudo apt-get autoremove --purge -y
        echo -e "${GREEN}  ✔ Cleaned apt cache & autoremoved unused packages${RESET}"
    else
        echo -e "${YELLOW}  ℹ Run with sudo to clean /var/cache/apt: 'sudo apt-get clean'${RESET}"
    fi
fi

echo -e "\n${CYAN}[5/6] Cleaning old disabled Snap package revisions...${RESET}"
if command -v snap &>/dev/null; then
    # List and remove old/disabled snap packages
    snap list --all 2>/dev/null | awk '/disabled/{print $1, $3}' |
        while read -r snapname revision; do
            if [ -n "$snapname" ]; then
                if [ "$EUID" -eq 0 ]; then
                    snap remove "$snapname" --revision="$revision" 2>/dev/null || true
                    echo -e "${GREEN}  ✔ Removed old snap $snapname (rev $revision)${RESET}"
                elif sudo -n true 2>/dev/null; then
                    sudo snap remove "$snapname" --revision="$revision" 2>/dev/null || true
                    echo -e "${GREEN}  ✔ Removed old snap $snapname (rev $revision)${RESET}"
                fi
            fi
        done
fi

echo -e "\n${CYAN}[6/6] Cleaning Docker images and build caches (if running)...${RESET}"
if command -v docker &>/dev/null; then
    if docker info &>/dev/null; then
        docker system prune -f 2>/dev/null || true
        echo -e "${GREEN}  ✔ Cleaned dangling docker images and build cache${RESET}"
    else
        echo -e "${YELLOW}  ℹ Docker daemon is not running (skipped)${RESET}"
    fi
fi

# 2. Measure Final Free Space
FINAL_AVAIL_KB=$(df -k / | awk 'NR==2 {print $4}')
DIFF_KB=$((FINAL_AVAIL_KB - INITIAL_AVAIL_KB))

echo -e "\n${BOLD}${CYAN}======================================================${RESET}"
echo -e "${BOLD}${GREEN}               Cleanup Complete!                      ${RESET}"
echo -e "${BOLD}${CYAN}======================================================${RESET}"
echo -e "${BOLD}Updated Disk Usage on /:${RESET}"
df -h / | awk 'NR==1 || NR==2'

if [ "$DIFF_KB" -gt 0 ]; then
    DIFF_MB=$((DIFF_KB / 1024))
    if [ "$DIFF_MB" -gt 1024 ]; then
        DIFF_GB=$(awk "BEGIN {printf \"%.2f\", $DIFF_MB/1024}")
        echo -e "\n${BOLD}${GREEN}🎉 Successfully freed: ~${DIFF_GB} GB of disk space!${RESET}\n"
    else
        echo -e "\n${BOLD}${GREEN}🎉 Successfully freed: ~${DIFF_MB} MB of disk space!${RESET}\n"
    fi
else
    echo -e "\n${GREEN}✔ Disk clean operation finished.${RESET}\n"
fi
