import 'models/dtc_record.dart';

/// Decodes Mode 03 / Mode 07 Diagnostic Trouble Codes
class DtcDecoder {
  static const Map<int, String> _prefixMap = {
    0: 'P', // Powertrain
    1: 'C', // Chassis
    2: 'B', // Body
    3: 'U', // Network
  };

  /// Decodes raw Mode 03 response hex (e.g. "43 01 71 03 00 00 00") into DTC codes
  static List<String> decodeDtcCodes(String rawHex) {
    final clean = rawHex.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();
    final idx = clean.indexOf('43');
    if (idx == -1) return [];

    final payload = clean.substring(idx + 2);
    final codes = <String>[];

    for (int i = 0; i + 3 < payload.length; i += 4) {
      final b1Hex = payload.substring(i, i + 2);
      final b2Hex = payload.substring(i + 2, i + 4);

      final b1 = int.tryParse(b1Hex, radix: 16) ?? 0;
      final b2 = int.tryParse(b2Hex, radix: 16) ?? 0;

      // 00 00 is padding / no code
      if (b1 == 0 && b2 == 0) continue;

      final prefixType = (b1 >> 6) & 0x03;
      final prefix = _prefixMap[prefixType] ?? 'P';
      final digit1 = (b1 >> 4) & 0x03;
      final digit2 = (b1 & 0x0F).toRadixString(16).toUpperCase();
      final digit3 = ((b2 >> 4) & 0x0F).toRadixString(16).toUpperCase();
      final digit4 = (b2 & 0x0F).toRadixString(16).toUpperCase();

      final code = '$prefix$digit1$digit2$digit3$digit4';
      if (!codes.contains(code)) {
        codes.add(code);
      }
    }

    return codes;
  }

  /// Create DtcRecord objects with basic severity classification
  static List<DtcRecord> parseToRecords(String rawHex) {
    final codes = decodeDtcCodes(rawHex);
    final now = DateTime.now();

    return codes.map((code) {
      String severity = 'WARNING';
      // Misfire codes or critical powertrain issues
      if (code.startsWith('P03') || code.startsWith('P02')) {
        severity = 'CRITICAL';
      } else if (code.startsWith('B') || code.startsWith('U')) {
        severity = 'INFO';
      }

      return DtcRecord(
        code: code,
        severity: severity,
        milActive: true,
        detectedAt: now,
      );
    }).toList();
  }
}
