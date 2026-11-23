class AppConfig {
  static const String appName = 'EngineBeats';
  static const String appVersion = '1.0.0';

  // In Android Emulator use 10.0.2.2, in iOS / Desktop use 127.0.0.1
  static const String defaultApiBaseUrl = 'http://127.0.0.1:8081';
  static const String defaultAuthIssuer = 'http://127.0.0.1:8080/auth/realms/engine-beats';

  // Default ELM327 WiFi Dongle / Emulator address
  static const String defaultDongleHost = '127.0.0.1';
  static const int defaultDonglePort = 35000;

  // Telemetry Sync Interval (seconds)
  static const int batchUploadIntervalSec = 15;
}
