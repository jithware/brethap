// To execute test run:
// flutter test integration_test/sessions_test.dart

import 'package:brethap/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:brethap/main.dart' as app;
import '../test/home_widget_test.dart';
import 'demo_test.dart';
import 'screenshot.dart';

Future<void> testSessions(
  WidgetTester tester, [
  IntegrationTestWidgetsFlutterBinding? binding,
]) async {
  await tester.pump(demoWait);

  // open drawer
  await openDrawer(tester);

  if (binding != null) {
    await tester.pumpAndSettle();
    takeScreenshot(binding, "3_drawer.png");
  }

  // tap sessions
  await tester.pump(demoWait);
  await tapItem(tester, HomeWidget.keySessions);

  if (binding != null) {
    await tester.pumpAndSettle();
    takeScreenshot(binding, "6_sessions.png");
  }

  // tap stats
  await tester.pump(demoWait);
  Finder finder = find.byType(FloatingActionButton);
  expect(finder, findsOneWidget);
  await tester.tap(finder);

  if (binding != null) {
    await tester.pumpAndSettle();
    takeScreenshot(binding, "7_stats.png");
  }

  // snack bar close
  await tester.pump(snackbar);
  await tester.pump(demoWait);

  // remove session
  Duration duration = const Duration(milliseconds: 500);
  double drag = 500;
  finder = find.byKey(Key('${HomeWidget.totalSessions - 1}')); // last session
  expect(finder, findsOneWidget);
  await tester.timedDrag(finder, Offset(drag, 0), duration);
  await tester.pump(demoWait * 2);

  // go back
  await goBack(tester);

  // close the drawer
  await closeDrawer(tester);

  await tester.pump(demoWait);
}

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test Sessions', skip: false, (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle();
    await tester.pump(demoWait);

    String envVars = "";
    Duration startDuration = Duration.zero;
    Stopwatch stopwatch = Stopwatch()..start();

    await testSessions(tester, binding);

    envVars += "$testStart=$startDuration\n";
    envVars += "$testEnd=${stopwatch.elapsed}\n";
    debugPrint(envVars);
  });
}
