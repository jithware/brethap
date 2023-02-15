import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:brethap/constants.dart';
import 'package:brethap/home_widget.dart';
import 'package:brethap/hive_storage.dart';
import 'package:brethap/wear.dart';
import 'test_utils.dart';

const Duration wait = Duration(seconds: 2);

Future<void> openDrawer(WidgetTester tester) async {
  Finder navigationMenu = find.byType(IconButton).first;
  expect(navigationMenu, findsOneWidget);
  await tester.tap(navigationMenu, warnIfMissed: false);
  await tester.pump(wait * .5);
  await tester.pump(wait * .5);
}

Future<void> closeDrawer(WidgetTester tester) async {
  Size size = tester.getSize(find.byType(Scaffold));
  await tester.flingFrom(
      Offset(size.width - 1, size.height / 2), const Offset(-100, 0), 1000);
  await tester.pump(wait * .5);
  await tester.pump(wait * .5);
}

Future<void> testPreferencesMenu(WidgetTester tester, String key) async {
  Finder finder = find.byType(IconButton).last;
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(wait * .5);
  await tester.pump(wait * .5);
  finder = find.byKey(Key(key));
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(wait * .5);
  await tester.pump(wait * .5);
}

Future<void> testHomeWidget(WidgetTester tester) async {
  const Duration shortWait = Duration(milliseconds: 500);
  Preference preference = Preference.getDefaultPref();
  Duration duration = Duration(seconds: preference.duration),
      totalTime = const Duration(),
      inhale =
          Duration(milliseconds: preference.inhale[0] + preference.inhale[1]),
      exhale =
          Duration(milliseconds: preference.exhale[0] + preference.exhale[1]);

  // Verify app name in title bar
  expect(find.text(APP_NAME), findsOneWidget);

  // Verify initial status text
  expect(find.text(PRESS_BUTTON_TEXT), findsOneWidget);

  // Verify initial timer text
  expect(find.text(getDurationString(duration)), findsOneWidget);

  // Press start button
  await tester.tap(find.byType(FloatingActionButton));

  // Wait a bit
  await tester.pump(shortWait);
  totalTime += shortWait;

  // Verify status text
  expect(find.text(INHALE_TEXT), findsOneWidget);

  // Verify timer
  expect(find.text(getDurationString(duration - totalTime)), findsOneWidget);

  // Forward ahead to exhale
  await tester.pump(inhale);
  totalTime += inhale;

  // Verify timer
  expect(find.text(getDurationString(duration - totalTime)), findsOneWidget);

  // Wait a bit
  await tester.pump(shortWait);
  totalTime += shortWait;

  // Verify status text
  expect(find.text(EXHALE_TEXT), findsOneWidget);

  // Forward ahead to inhale
  await tester.pump(exhale);
  totalTime += exhale;

  // Press stop button
  await tester.tap(find.byType(FloatingActionButton));

  // Wait a bit
  await tester.pump(shortWait);
  totalTime += shortWait;

  // Verify reset status text
  expect(find.text(PRESS_BUTTON_TEXT), findsOneWidget);

  // Verify reset timer text
  expect(find.text(getDurationString(duration)), findsOneWidget);

  // Verify session
  await tester.pump(shortWait);
  totalTime += shortWait;
  expect(find.byType(SnackBar), findsOneWidget);

  // Open the drawer
  await openDrawer(tester);

  // Verify app name in drawer header
  expect(find.text(APP_NAME), findsNWidgets(2));

  // Verify preferences
  expect(find.text(HomeWidget.keyPreferences), findsOneWidget);

  // Verify sessions
  expect(find.text(HomeWidget.keySessions), findsOneWidget);

  // Verify calendar
  expect(find.text(HomeWidget.keyCalendar), findsOneWidget);

  // Verify about
  expect(find.text("About $APP_NAME"), findsOneWidget);

  // Close the drawer
  await closeDrawer(tester);

  // Verify preferences menu
  await testPreferencesMenu(tester, HomeWidget.keyNoPreferences);

  await tester.pumpAndSettle();
}

Future<void> main() async {
  late HiveData hiveData;
  setUpAll((() async {
    hiveData = await setupHive();
  }));

  tearDownAll((() async {}));

  testWidgets('HomeWidget', (WidgetTester tester) async {
    const String APP_VERSION = "1.0.0";
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeWidget(
          appName: APP_NAME,
          version: APP_VERSION,
          preferences: hiveData.preferences,
          sessions: hiveData.sessions,
        )));

    await testHomeWidget(tester);

    await tester.pump();
  });
}
