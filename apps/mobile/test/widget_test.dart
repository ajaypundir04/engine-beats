import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:engine_beats_mobile/main.dart';

void main() {
  testWidgets('App renders login screen when unauthenticated', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EngineBeatsApp()));

    expect(find.text('EngineBeats'), findsOneWidget);
    expect(find.text('Connected Vehicle Telemetry & Diagnostics'), findsOneWidget);
    expect(find.text('Log In / Connect'), findsOneWidget);
  });
}
