/// Decodes raw OBD-II Mode 01 hex payloads into physical engineering units.
class PidDecoder {
  /// Strips formatting, spaces, and validates Mode 01 response prefix (41)
  static List<int>? extractBytes(String rawHex, String expectedPid) {
    final clean = rawHex.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();
    final expectedPrefix = '41${expectedPid.toUpperCase().replaceAll('01', '')}';

    final idx = clean.indexOf(expectedPrefix);
    if (idx == -1) return null;

    final dataHex = clean.substring(idx + expectedPrefix.length);
    final bytes = <int>[];
    for (int i = 0; i + 1 < dataHex.length; i += 2) {
      final b = int.tryParse(dataHex.substring(i, i + 2), radix: 16);
      if (b != null) bytes.add(b);
    }
    return bytes;
  }

  /// Decode Engine RPM (Mode 01 PID 0C) -> ((A * 256) + B) / 4
  static double? decodeRpm(String raw) {
    final bytes = extractBytes(raw, '0C');
    if (bytes == null || bytes.length < 2) return null;
    return ((bytes[0] * 256) + bytes[1]) / 4.0;
  }

  /// Decode Vehicle Speed in km/h (Mode 01 PID 0D) -> A
  static double? decodeSpeed(String raw) {
    final bytes = extractBytes(raw, '0D');
    if (bytes == null || bytes.isEmpty) return null;
    return bytes[0].toDouble();
  }

  /// Decode Engine Coolant Temp in °C (Mode 01 PID 05) -> A - 40
  static int? decodeCoolantTemp(String raw) {
    final bytes = extractBytes(raw, '05');
    if (bytes == null || bytes.isEmpty) return null;
    return bytes[0] - 40;
  }

  /// Decode Throttle Position in % (Mode 01 PID 11) -> (A * 100) / 255
  static double? decodeThrottlePos(String raw) {
    final bytes = extractBytes(raw, '11');
    if (bytes == null || bytes.isEmpty) return null;
    return (bytes[0] * 100.0) / 255.0;
  }

  /// Decode Fuel Tank Level in % (Mode 01 PID 2F) -> (A * 100) / 255
  static double? decodeFuelLevel(String raw) {
    final bytes = extractBytes(raw, '2F');
    if (bytes == null || bytes.isEmpty) return null;
    return (bytes[0] * 100.0) / 255.0;
  }

  /// Decode MAF Air Flow Rate in g/s (Mode 01 PID 10) -> ((A * 256) + B) / 100
  static double? decodeMaf(String raw) {
    final bytes = extractBytes(raw, '10');
    if (bytes == null || bytes.length < 2) return null;
    return ((bytes[0] * 256) + bytes[1]) / 100.0;
  }

  /// Decode Engine Load in % (Mode 01 PID 04) -> (A * 100) / 255
  static double? decodeEngineLoad(String raw) {
    final bytes = extractBytes(raw, '04');
    if (bytes == null || bytes.isEmpty) return null;
    return (bytes[0] * 100.0) / 255.0;
  }

  /// Decode Battery Voltage from ATRV response (e.g. "12.6V")
  static double? decodeBatteryVoltage(String raw) {
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*V', caseSensitive: false).firstMatch(raw);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    // Alternatively Mode 01 PID 42: ((A * 256) + B) / 1000
    final bytes = extractBytes(raw, '42');
    if (bytes != null && bytes.length >= 2) {
      return ((bytes[0] * 256) + bytes[1]) / 1000.0;
    }
    return null;
  }
}
