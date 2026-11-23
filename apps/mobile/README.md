# EngineBeats Mobile App (`apps/mobile`)

Cross-platform Flutter mobile client for iOS and Android.

## Features
- **ELM327 OBD-II Dongle Connection**: Supports both Bluetooth Low Energy (BLE) and WiFi/TCP socket connections (e.g., Vgate iCar WiFi, or local simulator at `127.0.0.1:35000`).
- **Live Cockpit**: High-FPS circular gauges for Vehicle Speed and Engine RPM, alongside telemetry metrics (Coolant Temp, Throttle %, Fuel Tank Level, Battery Voltage, MAF).
- **Diagnostics (DTC)**: One-tap ECU scanning for active/pending trouble codes with severity badges and ECU fault memory clearing.
- **Trip Computer**: Live distance, speed, and fuel tracking with offline buffering and automatic background batch sync to the backend API.
- **Entitlements & Subscriptions**: Gated features (cloud trip sync, CSV export, multi-vehicle fleet) connected to backend entitlements via Stripe Checkout / RevenueCat store receipts.

## Running the App
```bash
flutter pub get
flutter run
```

To connect to the local Python ELM327 simulator:
- On Desktop / Chrome / iOS Simulator: Connect to `127.0.0.1:35000`.
- On Android Emulator: Connect to `10.0.2.2:35000`.
