# ELM327 OBD-II Vehicle Simulator

Simulates an OBD-II compliant vehicle responding through a standard ELM327 WiFi/TCP adapter (port 35000).

## Features
- Dynamic engine physics simulation (revving RPM, speed acceleration curve, engine coolant warm up, MAF air flow, alternator voltage).
- ELM327 AT Commands (`ATZ`, `ATE0`, `ATH0`, `ATS0`, `ATSP0`, `ATRV`, `ATDP`).
- Mode 01 PIDs:
  - `0100`: Supported PIDs
  - `0104`: Engine Load
  - `0105`: Coolant Temperature
  - `010C`: Engine RPM
  - `010D`: Vehicle Speed
  - `0110`: MAF Air Flow Rate
  - `0111`: Throttle Position
  - `012F`: Fuel Tank Level
- Mode 03 & 04: Trouble Codes (DTCs `P0171`, `P0300`) and Clear DTC command.

## Usage
Run directly:
```bash
python3 elm327_server.py
```
Or with Docker:
```bash
docker run -p 35000:35000 enginebeats-elm327-emulator
```
