import 'package:test/test.dart';
import 'package:obd_core/obd_core.dart';

void main() {
  group('PidDecoder Tests', () {
    test('Decode Engine RPM (010C)', () {
      // 0x2710 = 10000 -> 10000 / 4 = 2500.0 RPM
      const raw = '41 0C 27 10';
      final rpm = PidDecoder.decodeRpm(raw);
      expect(rpm, equals(2500.0));

      // Without spaces
      expect(PidDecoder.decodeRpm('410C2710'), equals(2500.0));

      // Idle RPM: 800 RPM -> 3200 = 0x0C80
      expect(PidDecoder.decodeRpm('41 0C 0C 80'), equals(800.0));
    });

    test('Decode Vehicle Speed (010D)', () {
      // 0x41 = 65 km/h
      const raw = '41 0D 41';
      expect(PidDecoder.decodeSpeed(raw), equals(65.0));

      // 0 km/h
      expect(PidDecoder.decodeSpeed('41 0D 00'), equals(0.0));

      // 120 km/h (0x78)
      expect(PidDecoder.decodeSpeed('41 0D 78'), equals(120.0));
    });

    test('Decode Engine Coolant Temp (0105)', () {
      // 90 °C -> 90 + 40 = 130 = 0x82
      expect(PidDecoder.decodeCoolantTemp('41 05 82'), equals(90));

      // 0 °C -> 0 + 40 = 40 = 0x28
      expect(PidDecoder.decodeCoolantTemp('41 05 28'), equals(0));

      // -20 °C -> -20 + 40 = 20 = 0x14
      expect(PidDecoder.decodeCoolantTemp('41 05 14'), equals(-20));
    });

    test('Decode Throttle Position (0111)', () {
      // 50% -> 128 / 255 * 100
      final val = PidDecoder.decodeThrottlePos('41 11 80');
      expect(val, isNotNull);
      expect(val!, closeTo(50.19, 0.1));

      // 100% -> 0xFF
      expect(PidDecoder.decodeThrottlePos('41 11 FF'), closeTo(100.0, 0.01));

      // 0% -> 0x00
      expect(PidDecoder.decodeThrottlePos('41 11 00'), equals(0.0));
    });

    test('Decode Fuel Tank Level (012F)', () {
      // 75% -> 0xBF (191) -> 191 * 100 / 255 = 74.9%
      expect(PidDecoder.decodeFuelLevel('41 2F BF'), closeTo(74.9, 0.2));
    });

    test('Decode MAF Air Flow (0110)', () {
      // 15.5 g/s -> 1550 = 0x060E
      expect(PidDecoder.decodeMaf('41 10 06 0E'), closeTo(15.5, 0.01));
    });

    test('Decode Battery Voltage (ATRV)', () {
      expect(PidDecoder.decodeBatteryVoltage('12.6V'), equals(12.6));
      expect(PidDecoder.decodeBatteryVoltage('13.8V\r\n'), equals(13.8));
      expect(PidDecoder.decodeBatteryVoltage('14.2 V'), equals(14.2));
    });

    test('Invalid / No Data handling', () {
      expect(PidDecoder.decodeRpm('NO DATA'), isNull);
      expect(PidDecoder.decodeSpeed('CAN ERROR'), isNull);
    });
  });
}
