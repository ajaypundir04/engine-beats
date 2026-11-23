import 'package:test/test.dart';
import 'package:obd_core/obd_core.dart';

void main() {
  group('DtcDecoder Tests', () {
    test('Decode single and multiple DTCs', () {
      // 0x0171 -> P0171, 0x0300 -> P0300
      const raw = '43 01 71 03 00 00 00';
      final codes = DtcDecoder.decodeDtcCodes(raw);

      expect(codes.length, equals(2));
      expect(codes[0], equals('P0171'));
      expect(codes[1], equals('P0300'));
    });

    test('Decode Chassis, Body, and Network DTCs', () {
      // Chassis: C0035 (left front wheel speed sensor)
      // C -> prefix 01 -> 0b01000000 = 0x40 -> 0x4035
      final codes = DtcDecoder.decodeDtcCodes('43 40 35 00 00');
      expect(codes.length, equals(1));
      expect(codes[0], equals('C0035'));
    });

    test('Empty / No DTCs response', () {
      const raw = '43 00 00 00 00 00 00';
      final codes = DtcDecoder.decodeDtcCodes(raw);
      expect(codes, isEmpty);
    });

    test('Severity classification', () {
      final records = DtcDecoder.parseToRecords('43 03 00 00 00');
      expect(records.length, equals(1));
      expect(records[0].code, equals('P0300'));
      expect(records[0].severity, equals('CRITICAL'));
    });
  });
}
