#!/usr/bin/env bash
# ==============================================================================
# EngineBeats - Local Development Runner & Dummy Log Generator
# ==============================================================================
# Usage:
#   ./run-local.sh          # Start local emulator, generate dummy logs & stream
#   ./run-local.sh start    # Start in background
#   ./run-local.sh stop     # Stop background services
#   ./run-local.sh status   # Check status of local processes
#   ./run-local.sh logs     # Tail active log file
# ==============================================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

LOGS_DIR="$PROJECT_ROOT/logs"
PID_FILE="$PROJECT_ROOT/.run-local.pid"
MAIN_LOG="$LOGS_DIR/enginebeats-local.log"
DUMMY_OBD_LOG="$LOGS_DIR/dummy_obd_trip.log"
DUMMY_JSON_LOG="$LOGS_DIR/dummy_telemetry.json"
EMULATOR_LOG="$LOGS_DIR/elm327-emulator.log"
EMULATOR_PORT="${EMULATOR_PORT:-35000}"

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

mkdir -p "$LOGS_DIR"

# ------------------------------------------------------------------------------
# Generate Dummy OBD Trip Log File (Raw ELM327 Serial/Socket Traffic)
# ------------------------------------------------------------------------------
generate_dummy_logs() {
    echo -e "${CYAN}[*] Generating realistic dummy vehicle logs in $LOGS_DIR...${RESET}"

    # 1. Raw ELM327 Hex Trace Log
    cat << 'EOF' > "$DUMMY_OBD_LOG"
# =====================================================================
# EngineBeats Dummy OBD-II Vehicle Diagnostic Session
# Vehicle: 2021 Honda Accord Sport 2.0T (VIN: 1HGCR2F83HA123456)
# Protocol: ISO 15765-4 (CAN 11-bit / 500 kbaud)
# Adapter: ELM327 v1.5 WiFi Interface (127.0.0.1:35000)
# Capture Profile: Urban Commute with Stop-and-Go & Highway Acceleration
# =====================================================================

2026-11-23T19:35:00.100Z [TX] ATZ
2026-11-23T19:35:00.220Z [RX] ELM327 v1.5
2026-11-23T19:35:00.225Z [TX] ATE0
2026-11-23T19:35:00.245Z [RX] OK
2026-11-23T19:35:00.250Z [TX] ATH0
2026-11-23T19:35:00.270Z [RX] OK
2026-11-23T19:35:00.275Z [TX] ATS0
2026-11-23T19:35:00.295Z [RX] OK
2026-11-23T19:35:00.300Z [TX] ATSP0
2026-11-23T19:35:00.320Z [RX] OK
2026-11-23T19:35:00.325Z [TX] ATRV
2026-11-23T19:35:00.345Z [RX] 12.6V

# Engine Crank & Warm-up Phase
2026-11-23T19:35:01.000Z [TX] 010C
2026-11-23T19:35:01.040Z [RX] 41 0C 0D 80    # RPM: 864 rpm (Engine Idle)
2026-11-23T19:35:01.045Z [TX] 010D
2026-11-23T19:35:01.075Z [RX] 41 0D 00       # Speed: 0 km/h (Stationary)
2026-11-23T19:35:01.080Z [TX] 0105
2026-11-23T19:35:01.110Z [RX] 41 05 55       # Coolant: 45 °C
2026-11-23T19:35:01.115Z [TX] 0111
2026-11-23T19:35:01.140Z [RX] 41 11 25       # Throttle: 14.5%
2026-11-23T19:35:01.145Z [TX] 012F
2026-11-23T19:35:01.170Z [RX] 41 2F B3       # Fuel Level: 70.2%
2026-11-23T19:35:01.175Z [TX] ATRV
2026-11-23T19:35:01.200Z [RX] 14.1V          # Alternator Charging Active

# Acceleration & Cruising Phase
2026-11-23T19:35:05.000Z [TX] 010C
2026-11-23T19:35:05.035Z [RX] 41 0C 23 28    # RPM: 2250 rpm (Cruising)
2026-11-23T19:35:05.040Z [TX] 010D
2026-11-23T19:35:05.065Z [RX] 41 0D 32       # Speed: 50 km/h
2026-11-23T19:35:05.070Z [TX] 0110
2026-11-23T19:35:05.095Z [RX] 41 10 05 DC    # MAF: 15.00 g/s
2026-11-23T19:35:05.100Z [TX] 0111
2026-11-23T19:35:05.125Z [RX] 41 11 4A       # Throttle: 29.0%
2026-11-23T19:35:05.130Z [TX] 0105
2026-11-23T19:35:05.155Z [RX] 41 05 78       # Coolant: 80 °C

# Highway Pull
2026-11-23T19:35:10.000Z [TX] 010C
2026-11-23T19:35:10.035Z [RX] 41 0C 36 B0    # RPM: 3500 rpm (Overtaking)
2026-11-23T19:35:10.040Z [TX] 010D
2026-11-23T19:35:10.065Z [RX] 41 0D 64       # Speed: 100 km/h
2026-11-23T19:35:10.070Z [TX] 0104
2026-11-23T19:35:10.095Z [RX] 41 04 80       # Engine Load: 50.2%
2026-11-23T19:35:10.100Z [TX] 0105
2026-11-23T19:35:10.125Z [RX] 41 05 84       # Coolant: 92 °C (Operating Temp)

# ECU Diagnostic Scan Mode 03 (Request Active DTCs)
2026-11-23T19:35:15.000Z [TX] 03
2026-11-23T19:35:15.080Z [RX] 43 01 71 03 00 00 00
# Decoded DTCs:
#   -> P0171: Powertrain / Fuel & Air Metering (System Too Lean Bank 1)
#   -> P0300: Powertrain / Ignition System (Random/Multiple Cylinder Misfire Detected)

# Clear DTCs Mode 04 Request
2026-11-23T19:35:20.000Z [TX] 04
2026-11-23T19:35:20.120Z [RX] 44             # Positive Response: DTCs Cleared
EOF

    # 2. Structured JSON Telemetry Batch
    cat << 'EOF' > "$DUMMY_JSON_LOG"
[
  {
    "batchId": "b101c001-2026-4000-8000-000000000001",
    "vehicleId": "v1000000-0000-0000-0000-000000000001",
    "tripId": "t1000000-0000-0000-0000-000000000001",
    "readings": [
      {
        "timestamp": "2026-11-23T19:35:00Z",
        "rpm": 850.0,
        "speedKmh": 0.0,
        "coolantTempC": 50,
        "throttlePosPct": 14.5,
        "fuelLevelPct": 70.2,
        "mafGps": 3.4,
        "batteryVoltage": 14.1,
        "ambientTempC": 18,
        "engineLoadPct": 19.5
      },
      {
        "timestamp": "2026-11-23T19:35:05Z",
        "rpm": 2250.0,
        "speedKmh": 50.0,
        "coolantTempC": 80,
        "throttlePosPct": 29.0,
        "fuelLevelPct": 70.1,
        "mafGps": 15.0,
        "batteryVoltage": 13.9,
        "ambientTempC": 18,
        "engineLoadPct": 38.0
      },
      {
        "timestamp": "2026-11-23T19:35:10Z",
        "rpm": 3500.0,
        "speedKmh": 100.0,
        "coolantTempC": 92,
        "throttlePosPct": 54.0,
        "fuelLevelPct": 69.8,
        "mafGps": 28.5,
        "batteryVoltage": 13.8,
        "ambientTempC": 18,
        "engineLoadPct": 52.4
      }
    ]
  }
]
EOF

    echo -e "${GREEN}[✔] Created dummy log files:${RESET}"
    echo -e "    - OBD Trace Log:   ${BOLD}$DUMMY_OBD_LOG${RESET}"
    echo -e "    - JSON Telemetry:  ${BOLD}$DUMMY_JSON_LOG${RESET}"
}

# ------------------------------------------------------------------------------
# Check Status
# ------------------------------------------------------------------------------
status() {
    if [ -f "$PID_FILE" ]; then
        PIDS=$(cat "$PID_FILE")
        ALIVE=0
        for pid in $PIDS; do
            if kill -0 "$pid" 2>/dev/null; then
                ALIVE=1
            fi
        done
        if [ "$ALIVE" -eq 1 ]; then
            echo -e "${GREEN}[●] EngineBeats local services are running.${RESET}"
            echo -e "    - PIDs: $PIDS"
            echo -e "    - OBD Emulator Port: $EMULATOR_PORT"
            echo -e "    - Active Log: $MAIN_LOG"
            return 0
        fi
    fi
    echo -e "${YELLOW}[○] EngineBeats local services are stopped.${RESET}"
    return 1
}

# ------------------------------------------------------------------------------
# Stop Services
# ------------------------------------------------------------------------------
stop() {
    if [ -f "$PID_FILE" ]; then
        echo -e "${CYAN}[*] Stopping EngineBeats local services...${RESET}"
        PIDS=$(cat "$PID_FILE")
        for pid in $PIDS; do
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid" 2>/dev/null || true
            fi
        done
        rm -f "$PID_FILE"
        echo -e "${GREEN}[✔] All local services stopped.${RESET}"
    else
        echo -e "${YELLOW}[*] No active services found in $PID_FILE.${RESET}"
    fi
}

# ------------------------------------------------------------------------------
# Start Services & Live Logger
# ------------------------------------------------------------------------------
start() {
    # Generate dummy log files first
    generate_dummy_logs

    # Stop any previous instances
    if [ -f "$PID_FILE" ]; then
        stop
    fi

    echo -e "\n${BOLD}${CYAN}======================================================${RESET}"
    echo -e "${BOLD}${CYAN}   EngineBeats - Starting Local Development Stack     ${RESET}"
    echo -e "${BOLD}${CYAN}======================================================${RESET}"

    # 1. Start Python ELM327 Car Emulator in background
    echo -e "${CYAN}[*] Launching ELM327 Vehicle Simulator on port $EMULATOR_PORT...${RESET}"
    PYTHONUNBUFFERED=1 EMULATOR_PORT="$EMULATOR_PORT" python3 -u "$PROJECT_ROOT/tools/elm327-emulator/elm327_server.py" > "$EMULATOR_LOG" 2>&1 &
    EMULATOR_PID=$!

    sleep 1

    if ! kill -0 "$EMULATOR_PID" 2>/dev/null; then
        echo -e "${RED}[✘] Failed to start ELM327 emulator. Check $EMULATOR_LOG:${RESET}"
        cat "$EMULATOR_LOG"
        exit 1
    fi

    # 2. Start Live Vehicle Telemetry Logger Daemon
    # Queries the simulator every second, updates physics, and logs to enginebeats-local.log
    PYTHONUNBUFFERED=1 python3 -u -c "
import socket, time, sys, datetime

sock = None
for attempt in range(10):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect(('127.0.0.1', $EMULATOR_PORT))
        break
    except Exception:
        time.sleep(0.5)

if not sock:
    sys.exit(1)

def query(cmd):
    sock.sendall((cmd + '\r').encode('ascii'))
    res = ''
    while '>' not in res:
        chunk = sock.recv(1024).decode('ascii', errors='ignore')
        if not chunk:
            break
        res += chunk
    return res.replace('\r', ' ').replace('\n', ' ').replace('>', '').strip()

# Handshake
query('ATZ')
query('ATE0')

with open('$MAIN_LOG', 'a') as f:
    f.write(f'--- EngineBeats Telemetry Stream Session Started: {datetime.datetime.now(datetime.timezone.utc).isoformat()} ---\n')
    f.flush()

    while True:
        ts = datetime.datetime.now(datetime.timezone.utc).isoformat()
        rpm_raw = query('010C')
        spd_raw = query('010D')
        tmp_raw = query('0105')
        thr_raw = query('0111')
        vlt_raw = query('ATRV')

        log_line = f'[{ts}] OBD_LIVE | RPM: {rpm_raw} | SPD: {spd_raw} | TMP: {tmp_raw} | THR: {thr_raw} | BAT: {vlt_raw}\n'
        f.write(log_line)
        f.flush()
        time.sleep(1.0)
" > /dev/null 2>&1 &
    LOGGER_PID=$!

    echo "$EMULATOR_PID $LOGGER_PID" > "$PID_FILE"

    echo -e "${GREEN}[✔] ELM327 Vehicle Simulator running (PID: $EMULATOR_PID) on 127.0.0.1:$EMULATOR_PORT${RESET}"
    echo -e "${GREEN}[✔] Telemetry Poller running (PID: $LOGGER_PID) streaming to $MAIN_LOG${RESET}"

    echo -e "\n${BOLD}Available Endpoints & Files:${RESET}"
    echo -e "  • Simulator Socket:     ${CYAN}127.0.0.1:$EMULATOR_PORT${RESET} (Connect with nc or Flutter app)"
    echo -e "  • Live Stream Log:      ${CYAN}$MAIN_LOG${RESET}"
    echo -e "  • Dummy OBD Trip Log:   ${CYAN}$DUMMY_OBD_LOG${RESET}"
    echo -e "  • Dummy Telemetry JSON: ${CYAN}$DUMMY_JSON_LOG${RESET}"
    echo -e "  • Emulator Console:     ${CYAN}$EMULATOR_LOG${RESET}"
    echo -e "\n${YELLOW}Press Ctrl+C to stop services, or run in background with: ./run-local.sh start${RESET}\n"
}

# ------------------------------------------------------------------------------
# Main Dispatcher
# ------------------------------------------------------------------------------
case "${1:-run}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    logs)
        if [ -f "$MAIN_LOG" ]; then
            tail -f "$MAIN_LOG"
        else
            echo -e "${YELLOW}[!] Log file not found. Starting services first...${RESET}"
            start
            tail -f "$MAIN_LOG"
        fi
        ;;
    run)
        start
        # Trap SIGINT (Ctrl+C) to gracefully stop background processes
        trap 'echo -e "\n${CYAN}[*] Interrupted by user. Shutting down...${RESET}"; stop; exit 0' SIGINT SIGTERM
        echo -e "${BOLD}Tailing live stream ($MAIN_LOG):${RESET}"
        tail -n 20 -f "$MAIN_LOG"
        ;;
    *)
        echo "Usage: $0 {run|start|stop|status|logs}"
        exit 1
        ;;
esac
