// To execute demo with screenshots saved run:
// flutter drive --no-pub --driver=integration_test/driver.dart --target=integration_test/demo_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:brethap/main.dart' as app;
import 'calendar_test.dart';
import 'preferences_test.dart';
import 'running_test.dart';
import 'sessions_test.dart';

const String testStart = "TEST_START", testEnd = "TEST_END";

const Duration demoWait = Duration(milliseconds: 1000);
const Duration snackbar = Duration(milliseconds: 4000);

Future<void> tapItem(WidgetTester tester, String key) async {
  Finder item = find.byKey(Key(key));
  expect(item, findsOneWidget);
  await tester.tap(item);
  await tester.pump(demoWait);
}

Future<void> goBack(WidgetTester tester) async {
  Finder back = find.byType(BackButton);
  expect(back, findsOneWidget);
  await tester.tap(back);
  await tester.pump(demoWait);
  await tester.pump(demoWait);
}

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  testWidgets('Demo', (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle();
    await tester.pump(demoWait);

    String envVars = "";
    Duration startDuration = Duration.zero;
    Stopwatch stopwatch = Stopwatch()..start();

    debugPrint("Demo Running...");
    await testRunning(tester, binding);

    debugPrint("Demo Sessions...");
    await testSessions(tester, binding);

    debugPrint("Demo Calendar...");
    await testCalendar(tester, binding);

    debugPrint("Demo Preferences...");
    await testPreferences(tester, binding);

    envVars += "$testStart=$startDuration\n";
    envVars += "$testEnd=${stopwatch.elapsed}\n";
    debugPrint(envVars);
  });
}
