# OBD Core (`obd_core`)

Pure Dart library for interacting with ELM327 adapters and decoding standard SAE J1979 OBD-II PIDs and DTC trouble codes.

## Features
- **ELM327 Command Engine**: Reset (`ATZ`), Echo, Headers, Protocols, Battery Voltage (`ATRV`).
- **Mode 01 PID Decoder**: Engine RPM, Vehicle Speed, Coolant Temp, Throttle %, Fuel %, MAF, Engine Load.
- **Mode 03/07 DTC Decoder**: Powertrain (P), Chassis (C), Body (B), Network (U) error code decoding.
- **Robust Stream Parser**: Handles chunked socket/BLE frames, strips prompts (`>`) and filters noise.

## Unit Testing
Run tests with:
```bash
dart test
```
