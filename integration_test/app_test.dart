// To execute test run:
// flutter test integration_test/app_test.dart

import 'package:brethap/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:brethap/main.dart' as app;

import '../test/home_widget_test.dart';
import '../test/preferences_widget_test.dart';
import '../test/sessions_widgets_test.dart';

const Duration wait = Duration(milliseconds: 500);

Future<void> tapItem(WidgetTester tester, String key) async {
  Finder item = find.byKey(Key(key));
  expect(item, findsOneWidget);
  await tester.tap(item);
  await tester.pump(wait);
}

Future<void> goBack(WidgetTester tester) async {
  Finder back = find.byType(BackButton);
  expect(back, findsOneWidget);
  await tester.tap(back);
  await tester.pump(wait);
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration test', (WidgetTester tester) async {
    app.main();

    // Allow splash screen to clear
    await tester.pump(wait * 3);
    await tester.pumpAndSettle();

    await testHomeWidget(tester);

    await openDrawer(tester);

    await tapItem(tester, HomeWidget.keyPreferences);

    await testPreferencesWidget(tester);

    await goBack(tester);

    await closeDrawer(tester);

    await openDrawer(tester);

    await tapItem(tester, HomeWidget.keySessions);

    await testSessionsWidget(tester);

    await goBack(tester);

    await closeDrawer(tester);

    await openDrawer(tester);

    await tapItem(tester, HomeWidget.keyCalendar);

    await testSessionsCalendarWidget(tester);

    await goBack(tester);

    await closeDrawer(tester);

    //await tester.pump(const Duration(seconds: 10));
  });
}
