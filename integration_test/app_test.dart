// To execute test run:
// flutter test integration_test/app_test.dart

import 'package:brethap/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  if (back.evaluate().isEmpty) {
    back = find.byIcon(Icons.arrow_back);
  }
  expect(back, findsOneWidget);
  await tester.tap(back);
  await tester.pumpAndSettle();
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration test', (WidgetTester tester) async {
    // Clear Hive for a clean test run
    await Hive.initFlutter();
    final packageInfo = await PackageInfo.fromPlatform();
    final major = packageInfo.version.split(".")[0];
    final minor = packageInfo.version.split(".")[1];
    await Hive.deleteBoxFromDisk("preferences.$major.$minor");
    await Hive.deleteBoxFromDisk("sessions");
    await Hive.deleteBoxFromDisk("custom_sounds");

    await app.main();

    // Allow splash screen to clear
    await tester.pump(wait * 3);
    await tester.pumpAndSettle();

    await testHomeWidget(tester);

    // Test Color Picker
    await openDrawer(tester);
    Finder colorCircles = find.byWidgetPredicate((widget) =>
        widget is GestureDetector &&
        widget.child is Container &&
        (widget.child as Container).decoration is BoxDecoration &&
        ((widget.child as Container).decoration as BoxDecoration).shape ==
            BoxShape.circle);
    expect(colorCircles, findsWidgets);
    await tester.tap(colorCircles.at(2), warnIfMissed: false);
    await tester.pumpAndSettle();

    await openDrawer(tester);
    await tester.pumpAndSettle();

    await tapItem(tester, HomeWidget.keyPreferences);
    await tester.pumpAndSettle();

    await testPreferencesWidget(tester);

    await goBack(tester);
    await tester.pumpAndSettle();

    await closeDrawer(tester);
    await tester.pumpAndSettle();

    await openDrawer(tester);
    await tester.pumpAndSettle();

    await tapItem(tester, HomeWidget.keySessions);
    await tester.pumpAndSettle();

    await testSessionsWidget(tester);

    await goBack(tester);
    await tester.pumpAndSettle();

    await closeDrawer(tester);
    await tester.pumpAndSettle();

    await openDrawer(tester);
    await tester.pumpAndSettle();

    await tapItem(tester, HomeWidget.keyCalendar);
    await tester.pumpAndSettle();

    await testSessionsCalendarWidget(tester);

    await goBack(tester);
    await tester.pumpAndSettle();

    await closeDrawer(tester);
    await tester.pumpAndSettle();
  });
}
