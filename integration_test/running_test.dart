// To execute test run:
// flutter test integration_test/running_test.dart

import 'package:brethap/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:brethap/main.dart' as app;
import '../test/home_widget_test.dart';
import 'demo_test.dart';
import 'screenshot.dart';

Future<void> testRunning(
  WidgetTester tester, [
  IntegrationTestWidgetsFlutterBinding? binding,
]) async {
  await tester.pump(demoWait);

  if (binding != null) {
    takeScreenshot(binding, "1_home.png");
    await tester.pumpAndSettle();
  }

  // tap status text do show/hide animation ring
  await tapItem(tester, HomeWidget.keyStatusText);
  await tester.pump(demoWait);
  await tapItem(tester, HomeWidget.keyStatusText);

  // tap start
  Finder finder = find.byType(FloatingActionButton);
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(demoWait);

  // running
  for (int i = 0; i < 100; i++) {
    if (i == 15) {
      if (binding != null) {
        takeScreenshot(binding, "2_inhale.png");
        await tester.pumpAndSettle();
      }
    }
    await tester.pump(const Duration(milliseconds: 100));
  }

  // tap stop
  finder = find.byType(FloatingActionButton);
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(demoWait);

  // snack bar close
  await tester.pump(snackbar);
  await tester.pumpAndSettle();

  // preferences menu
  await testPreferencesMenu(tester, HomeWidget.keyNoPreferences);

  await tester.pump(demoWait);
}

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test Running', skip: false, (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle();
    await tester.pump(demoWait);

    String envVars = "";
    Duration startDuration = Duration.zero;
    Stopwatch stopwatch = Stopwatch()..start();

    await testRunning(tester, binding);

    envVars += "$testStart=$startDuration\n";
    envVars += "$testEnd=${stopwatch.elapsed}\n";
    debugPrint(envVars);
  });
}
