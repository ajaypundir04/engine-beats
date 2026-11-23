#!/usr/bin/env python3
"""
EngineBeats ELM327 OBD-II Vehicle Simulator
Simulates a real car connected via a WiFi/TCP ELM327 adapter (e.g. port 35000).
Generates realistic dynamic vehicle telemetry (RPM, speed, temp, throttle, MAF)
and handles standard AT commands and Mode 01/03/04 diagnostic requests.
"""

from __future__ import annotations

import math
import os
import re
import socket
import sys
import threading
import time
from typing import Tuple

PORT = int(os.environ.get("EMULATOR_PORT", 35000))
BIND_HOST = os.environ.get("EMULATOR_BIND", "0.0.0.0")

class SimulatedVehicleState:
    def __init__(self):
        self.lock = threading.Lock()
        self.rpm = 850.0        # Idle RPM
        self.speed_kmh = 0.0    # Stationary
        self.coolant_temp_c = 45.0  # Warming up
        self.throttle_pct = 15.0
        self.fuel_level_pct = 68.0
        self.battery_v = 12.6
        self.engine_load_pct = 20.0
        self.maf_gps = 3.5
        self.dtc_codes = ["P0171", "P0300"]  # Simulated active DTCs
        self.time_offset = 0.0

    def update_physics(self, dt: float):
        """Simulate realistic driving patterns: accelerating, cruising, idling."""
        with self.lock:
            self.time_offset += dt
            t = self.time_offset

            # Simulate driving cycle with periodic acceleration and braking
            cycle = (math.sin(t * 0.15) + 1.0) / 2.0  # 0.0 to 1.0

            # Throttle variation
            self.throttle_pct = 12.0 + (cycle * 55.0)

            # RPM: idle 800 to 3800 rev
            self.rpm = 800.0 + (cycle * 2800.0) + (math.sin(t * 2.0) * 80.0)

            # Speed follows RPM with lag
            target_speed = cycle * 95.0
            self.speed_kmh += (target_speed - self.speed_kmh) * (dt * 0.8)

            # Coolant warms up towards 92°C
            if self.coolant_temp_c < 92.0:
                self.coolant_temp_c += dt * 0.2

            # MAF is proportional to RPM and throttle
            self.maf_gps = 3.2 + (self.rpm / 200.0) * (self.throttle_pct / 50.0)

            # Battery voltage fluctuates slightly with alternator
            self.battery_v = 13.9 + (math.sin(t * 0.5) * 0.3)

            # Engine load
            self.engine_load_pct = 18.0 + (self.throttle_pct * 0.8)

def encode_dtc(code: str) -> Tuple[int, int]:
    """Encode standard DTC like P0171 or C0300 into 2 bytes."""
    prefix = code[0].upper()
    prefix_bits = {"P": 0b00, "C": 0b01, "B": 0b10, "U": 0b11}.get(prefix, 0)
    first_digit = int(code[1])
    byte1 = (prefix_bits << 6) | (first_digit << 4) | int(code[2], 16)
    byte2 = (int(code[3], 16) << 4) | int(code[4], 16)
    return byte1, byte2

class Elm327Session:
    def __init__(self, client_sock: socket.socket, vehicle: SimulatedVehicleState):
        self.sock = client_sock
        self.vehicle = vehicle
        self.echo = True
        self.spaces = True
        self.headers = False
        self.protocol = "ISO 15765-4 (CAN 11/500)"

    def handle(self):
        buf = ""
        try:
            while True:
                data = self.sock.recv(1024)
                if not data:
                    break
                text = data.decode("ascii", errors="ignore")
                buf += text
                while "\r" in buf or "\n" in buf:
                    line, rest = re.split(r"[\r\n]+", buf, maxsplit=1)
                    buf = rest
                    cmd = line.strip()
                    if cmd:
                        self.process_command(cmd)
        except (ConnectionResetError, BrokenPipeError):
            pass
        finally:
            self.sock.close()

    def send_response(self, text: str):
        formatted = text
        if not self.spaces and not text.startswith("ELM") and not text.startswith("OK"):
            formatted = formatted.replace(" ", "")
        output = f"{formatted}\r\r>"
        self.sock.sendall(output.encode("ascii"))

    def process_command(self, cmd: str):
        normalized = cmd.upper().replace(" ", "")

        # Handle AT Commands
        if normalized.startswith("AT"):
            if normalized in ("ATZ", "ATWS"):
                time.sleep(0.1)
                self.send_response("ELM327 v1.5")
            elif normalized == "ATE0":
                self.echo = False
                self.send_response("OK")
            elif normalized == "ATE1":
                self.echo = True
                self.send_response("OK")
            elif normalized == "ATH0":
                self.headers = False
                self.send_response("OK")
            elif normalized == "ATH1":
                self.headers = True
                self.send_response("OK")
            elif normalized == "ATS0":
                self.spaces = False
                self.send_response("OK")
            elif normalized == "ATS1":
                self.spaces = True
                self.send_response("OK")
            elif normalized.startswith("ATSP"):
                self.send_response("OK")
            elif normalized == "ATDP":
                self.send_response(self.protocol)
            elif normalized == "ATRV":
                with self.vehicle.lock:
                    v = self.vehicle.battery_v
                self.send_response(f"{v:.1f}V")
            elif normalized in ("ATI", "AT@1"):
                self.send_response("ELM327 v1.5")
            else:
                self.send_response("OK")
            return

        # Handle Mode 01: Current Powertrain Diagnostic Data
        if normalized.startswith("01"):
            pid = normalized[2:4]
            with self.vehicle.lock:
                if pid == "00":
                    # PIDs 01-20 supported bitmap
                    self.send_response("41 00 BE 3F B8 11")
                elif pid == "20":
                    # PIDs 21-40 supported bitmap
                    self.send_response("41 20 80 00 00 01")
                elif pid == "04":
                    # Calculated engine load (A * 100 / 255)
                    val = int((self.vehicle.engine_load_pct / 100.0) * 255)
                    self.send_response(f"41 04 {val:02X}")
                elif pid == "05":
                    # Engine coolant temperature (A - 40 °C)
                    val = int(self.vehicle.coolant_temp_c + 40.0)
                    self.send_response(f"41 05 {val:02X}")
                elif pid == "0C":
                    # Engine RPM ((A * 256 + B) / 4)
                    raw = int(self.vehicle.rpm * 4.0)
                    a = (raw >> 8) & 0xFF
                    b = raw & 0xFF
                    self.send_response(f"41 0C {a:02X} {b:02X}")
                elif pid == "0D":
                    # Vehicle Speed (A km/h)
                    val = int(max(0, min(255, self.vehicle.speed_kmh)))
                    self.send_response(f"41 0D {val:02X}")
                elif pid == "10":
                    # MAF air flow rate ((A * 256 + B) / 100 g/s)
                    raw = int(self.vehicle.maf_gps * 100.0)
                    a = (raw >> 8) & 0xFF
                    b = raw & 0xFF
                    self.send_response(f"41 10 {a:02X} {b:02X}")
                elif pid == "11":
                    # Throttle position (A * 100 / 255)
                    val = int((self.vehicle.throttle_pct / 100.0) * 255)
                    self.send_response(f"41 11 {val:02X}")
                elif pid == "2F":
                    # Fuel Tank Level Input (A * 100 / 255)
                    val = int((self.vehicle.fuel_level_pct / 100.0) * 255)
                    self.send_response(f"41 2F {val:02X}")
                else:
                    self.send_response("NO DATA")
            return

        # Handle Mode 03: Request Diagnostic Trouble Codes (DTCs)
        if normalized == "03":
            with self.vehicle.lock:
                codes = list(self.vehicle.dtc_codes)
            if not codes:
                self.send_response("43 00 00 00 00 00 00")
            else:
                pairs = []
                for c in codes[:3]:
                    b1, b2 = encode_dtc(c)
                    pairs.append(f"{b1:02X} {b2:02X}")
                while len(pairs) < 3:
                    pairs.append("00 00")
                self.send_response(f"43 {' '.join(pairs)}")
            return

        # Handle Mode 04: Clear Diagnostic Trouble Codes
        if normalized == "04":
            with self.vehicle.lock:
                self.vehicle.dtc_codes.clear()
            self.send_response("44")
            return

        # Default fallback
        self.send_response("?")

def physics_loop(vehicle: SimulatedVehicleState):
    dt = 0.1
    while True:
        vehicle.update_physics(dt)
        time.sleep(dt)

def main():
    vehicle = SimulatedVehicleState()
    physics_thread = threading.Thread(target=physics_loop, args=(vehicle,), daemon=True)
    physics_thread.start()

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((BIND_HOST, PORT))
    server.listen(5)

    print(f"[*] EngineBeats ELM327 Vehicle Simulator listening on {BIND_HOST}:{PORT}")
    print("[*] Ready for WiFi/TCP OBD dongle connections (e.g. from Flutter app or test harness)")

    try:
        while True:
            client, addr = server.accept()
            print(f"[+] Client connected from {addr[0]}:{addr[1]}")
            session = Elm327Session(client, vehicle)
            threading.Thread(target=session.handle, daemon=True).start()
    except KeyboardInterrupt:
        print("\n[*] Shutting down simulator.")
    finally:
        server.close()

if __name__ == "__main__":
    main()
