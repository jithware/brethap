// To execute test run:
// flutter test integration_test/calendar_test.dart

import 'package:brethap/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:table_calendar/src/widgets/format_button.dart';

import 'package:brethap/main.dart' as app;
import '../test/home_widget_test.dart';
import 'demo_test.dart';
import 'screenshot.dart';

Future<void> testCalendar(
  WidgetTester tester, [
  IntegrationTestWidgetsFlutterBinding? binding,
]) async {
  await tester.pump(demoWait);

  // open drawer
  await openDrawer(tester);
  await tester.pump(demoWait);

  // tap calendar
  await tapItem(tester, HomeWidget.keyCalendar);

  // tap stats
  await tester.pump(demoWait);
  Finder finder = find.byType(FloatingActionButton);
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(demoWait);

  // snack bar close
  await tester.pump(snackbar);
  await tester.pump(demoWait);

  if (binding != null) {
    await tester.pumpAndSettle();
    takeScreenshot(binding, "8_calendar.png");
  }

  // tap week
  await tester.pump(demoWait);
  finder = find.byType(FormatButton);
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(demoWait);
  await tester.pump(demoWait);

  // tap month
  finder = find.byType(FormatButton);
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(demoWait);
  await tester.pump(demoWait);

  // go back
  await goBack(tester);

  // close the drawer
  await closeDrawer(tester);

  await tester.pump(demoWait);
}

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test Calendar', skip: false, (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle();
    await tester.pump(demoWait);

    String envVars = "";
    Duration startDuration = Duration.zero;
    Stopwatch stopwatch = Stopwatch()..start();

    await testCalendar(tester, binding);

    envVars += "$testStart=$startDuration\n";
    envVars += "$testEnd=${stopwatch.elapsed}\n";
    debugPrint(envVars);
  });
}
