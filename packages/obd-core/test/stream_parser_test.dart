import 'package:test/test.dart';
import 'package:obd_core/obd_core.dart';

void main() {
  group('Elm327StreamParser Tests', () {
    test('Buffers and emits on prompt character >', () async {
      final parser = Elm327StreamParser();
      final emitted = <String>[];

      parser.stream.listen((val) => emitted.add(val));

      // Stream incoming chunked bytes
      parser.addData('ELM327');
      parser.addData(' v1.5\r\r>');

      await Future.delayed(const Duration(milliseconds: 20));

      expect(emitted.length, equals(1));
      expect(emitted.first, equals('ELM327 v1.5'));

      parser.dispose();
    });

    test('Sanitizes BUS INIT and extra whitespace', () async {
      final parser = Elm327StreamParser();
      final emitted = <String>[];

      parser.stream.listen((val) => emitted.add(val));

      parser.addData('SEARCHING...\r\n41 0C 27 10\r\r>');
      await Future.delayed(const Duration(milliseconds: 20));

      expect(emitted.length, equals(1));
      expect(emitted.first, equals('41 0C 27 10'));

      parser.dispose();
    });

    test('Detects error responses', () {
      expect(Elm327StreamParser.isErrorResponse('NO DATA'), isTrue);
      expect(Elm327StreamParser.isErrorResponse('UNABLE TO CONNECT'), isTrue);
      expect(Elm327StreamParser.isErrorResponse('CAN ERROR'), isTrue);
      expect(Elm327StreamParser.isErrorResponse('41 0C 27 10'), isFalse);
    });
  });
}
