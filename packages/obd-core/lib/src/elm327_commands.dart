/// Standard ELM327 initialization and configuration AT commands
class Elm327Commands {
  static const String reset = 'ATZ';
  static const String echoOff = 'ATE0';
  static const String echoOn = 'ATE1';
  static const String headersOff = 'ATH0';
  static const String headersOn = 'ATH1';
  static const String spacesOff = 'ATS0';
  static const String spacesOn = 'ATS1';
  static const String autoProtocol = 'ATSP0';
  static const String describeProtocol = 'ATDP';
  static const String batteryVoltage = 'ATRV';
  static const String version = 'ATI';

  // Diagnostic Service Modes
  static const String mode01SupportedPids = '0100';
  static const String mode03RequestDtc = '03';
  static const String mode04ClearDtc = '04';

  /// Standard sequence executed when establishing an ELM327 connection
  static const List<String> initSequence = [
    reset,
    echoOff,
    spacesOff,
    headersOff,
    autoProtocol,
  ];
}
