import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brethap/constants.dart';
import 'package:brethap/home_widget.dart';
import 'package:brethap/hive_storage.dart';
import 'package:brethap/wear.dart';
import 'package:brethap/l10n/generated/app_localizations.dart';
import 'test_utils.dart';

const Duration wait = Duration(seconds: 2);

Future<void> openDrawer(WidgetTester tester) async {
  Finder navigationMenu = find.byTooltip('Open navigation menu');
  if (navigationMenu.evaluate().isEmpty) {
    navigationMenu = find.byIcon(Icons.menu);
  }
  expect(navigationMenu, findsOneWidget);
  await tester.tap(navigationMenu);
  await tester.pumpAndSettle();
}

Future<void> closeDrawer(WidgetTester tester) async {
  final double width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
  await tester.tapAt(Offset(width - 10, 400)); // Tap outside drawer
  await tester.pumpAndSettle();
}

Future<void> testPreferencesMenu(WidgetTester tester, String key) async {
  Finder finder = find.byIcon(Icons.bookmarks_outlined);
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  finder = find.byKey(Key(key));
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> testHomeWidget(WidgetTester tester) async {
  const Duration shortWait = Duration(milliseconds: 500);
  Preference preference = Preference.getDefaultPref();
  Duration
  duration = Duration(seconds: preference.duration),
  totalTime = const Duration(),
  inhale = Duration(milliseconds: preference.inhale[0] + preference.inhale[1]),
  exhale = Duration(milliseconds: preference.exhale[0] + preference.exhale[1]);

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

  // Verify timer (allow for small drift in integration tests)
  expect(
    find.byWidgetPredicate((widget) =>
        widget is Text &&
        widget.data != null &&
        [0, 1, -1, 2, -2].any((i) =>
            widget.data ==
            getDurationString(duration - totalTime + Duration(seconds: i)))),
    findsOneWidget,
  );

  // Forward ahead to exhale
  await tester.pump(inhale);
  totalTime += inhale;

  // Verify timer (allow for small drift in integration tests)
  expect(
    find.byWidgetPredicate((widget) =>
        widget is Text &&
        widget.data != null &&
        [0, 1, -1, 2, -2].any((i) =>
            widget.data ==
            getDurationString(duration - totalTime + Duration(seconds: i)))),
    findsOneWidget,
  );

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

  // Scroll to find custom tones
  Finder customTones = find.textContaining("Custom Tones");
  await tester.dragUntilVisible(
    customTones,
    find.byType(NavigationDrawer),
    const Offset(0, -200),
  );
  await tester.pumpAndSettle();

  // Verify custom tones
  expect(customTones, findsWidgets);
  expect(find.textContaining("Add Custom Sound"), findsOneWidget);

  // Verify appearance section
  expect(find.byType(GestureDetector), findsWidgets); // Color circles

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
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeWidget(
          appName: APP_NAME,
          version: APP_VERSION,
          preferences: hiveData.preferences,
          sessions: hiveData.sessions,
          customSounds: hiveData.customSounds,
        ),
      ),
    );

    await testHomeWidget(tester);

    await tester.pump();
  });
}
