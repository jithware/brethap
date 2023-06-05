// To execute demo run:
// flutter test integration_test/demo_test.dart
// To execute demo with screenshots saved run:
// flutter drive --no-pub --driver=integration_test/driver.dart --target=integration_test/demo_test.dart
// To execute demo script run:
// ./screenshots/demo.sh emulator-5554

import 'package:brethap/constants.dart';
import 'package:brethap/home_widget.dart';
import 'package:brethap/preferences_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:table_calendar/src/widgets/format_button.dart';

import 'package:brethap/main.dart' as app;
import '../test/home_widget_test.dart';
import '../test/preferences_widget_test.dart';
import 'screenshot.dart';

// ignore_for_file: dead_code
const bool demoRunning = true,
    demoSessions = true,
    demoCalendar = true,
    demoPreferences = true;

const Duration wait = Duration(milliseconds: 500);
const Duration snackbar = Duration(milliseconds: 4000);

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
  await tester.pump(wait);
}

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  testWidgets('Demo', (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();

    takeScreenshot(binding, "1_home.png");
    await Future.delayed(const Duration(seconds: 1));

    Stopwatch stopwatch = Stopwatch()..start();
    String envVars = "";

    // Running
    if (demoRunning) {
      debugPrint("Demo Running(${stopwatch.elapsed})...");
      await tester.pump(wait);

      // tap start
      Finder finder = find.byType(FloatingActionButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);

      // running
      for (int i = 0; i < 100; i++) {
        if (i == 20) {
          takeScreenshot(binding, "2_inhale.png");
        }
        await tester.pump(const Duration(milliseconds: 100));
      }

      // tap stop
      finder = find.byType(FloatingActionButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);

      // snack bar close
      await tester.pump(snackbar);
      await tester.pumpAndSettle();

      // preferences menu
      await testPreferencesMenu(tester, HomeWidget.keyNoPreferences);

      await tester.pump(wait);
      envVars += "RUNNING_END=${stopwatch.elapsed - wait}\n";
    }

    // Sessions
    if (demoSessions) {
      debugPrint("Demo Sessions(${stopwatch.elapsed})...");
      await tester.pump(wait);

      // open drawer
      await openDrawer(tester);

      await tester.pumpAndSettle();
      takeScreenshot(binding, "3_drawer.png");

      // tap sessions
      await tester.pump(wait);
      await tapItem(tester, HomeWidget.keySessions);

      await tester.pumpAndSettle();
      takeScreenshot(binding, "6_sessions.png");

      // tap stats
      await tester.pump(wait);
      Finder finder = find.byType(FloatingActionButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);

      await tester.pumpAndSettle();
      takeScreenshot(binding, "7_stats.png");

      // snack bar close
      await tester.pump(snackbar);
      await tester.pump(wait);

      // remove session
      Duration duration = const Duration(milliseconds: 500);
      double drag = 500;
      finder = find.byKey(const Key('200'));
      expect(finder, findsOneWidget);
      await tester.timedDrag(finder, Offset(drag, 0), duration);
      await tester.pump(wait * 2);

      // go back
      await goBack(tester);

      // close the drawer
      await closeDrawer(tester);

      await tester.pump(wait);
      envVars += "SESSIONS_END=${stopwatch.elapsed - wait}\n";
    }

    // Calendar
    if (demoCalendar) {
      debugPrint("Demo Calendar(${stopwatch.elapsed})...");

      await tester.pump(wait);

      // open drawer
      await openDrawer(tester);
      await tester.pump(wait);

      // tap calendar
      await tapItem(tester, HomeWidget.keyCalendar);

      // tap stats
      await tester.pump(wait);
      Finder finder = find.byType(FloatingActionButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);

      // snack bar close
      await tester.pump(snackbar);
      await tester.pump(wait);

      await tester.pumpAndSettle();
      takeScreenshot(binding, "8_calendar.png");

      // tap week
      await tester.pump(wait);
      finder = find.byType(FormatButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);
      await tester.pump(wait);

      // tap month
      finder = find.byType(FormatButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);
      await tester.pump(wait);

      // go back
      await goBack(tester);

      // close the drawer
      await closeDrawer(tester);

      await tester.pump(wait);
      envVars += "CALENDAR_END=${stopwatch.elapsed - wait}\n";
    }

    // Preferences
    if (demoPreferences) {
      debugPrint("Demo Preferences(${stopwatch.elapsed})...");
      await tester.pump(wait);

      // open drawer
      await openDrawer(tester);
      await tester.pump(wait);

      // tap preferences
      await tapItem(tester, HomeWidget.keyPreferences);

      await tester.pumpAndSettle();
      takeScreenshot(binding, "4_preferences.png");

      // drag minutes
      int drag = 20;
      Duration duration = Duration(milliseconds: drag * 10);
      Finder finder = find.byKey(const Key(DURATION_MINUTES_TEXT));
      expect(finder, findsOneWidget);
      Offset topLeft = tester.getTopLeft(finder);
      await tester.timedDragFrom(Offset(topLeft.dx + 20, topLeft.dy + 20),
          Offset(drag.toDouble(), 0), duration);
      await tester.pump(wait);

      // drag seconds
      drag = 90;
      duration = Duration(milliseconds: drag * 10);
      finder = find.byKey(const Key(DURATION_SECONDS_TEXT));
      expect(finder, findsOneWidget);
      topLeft = tester.getTopLeft(finder);
      await tester.timedDragFrom(Offset(topLeft.dx + 20, topLeft.dy + 20),
          Offset(drag.toDouble(), 0), duration);
      await tester.pump(wait);

      // tap tts
      finder = find.byKey(const Key(DURATION_TTS_TEXT));
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);

      // tap inhale audio
      finder = find.byKey(const Key(INHALE_AUDIO_TEXT), skipOffstage: false);
      expect(finder, findsOneWidget);
      await tester.ensureVisible(finder);
      await tester.pump(wait);
      await tester.tap(finder);
      await tester.pump(wait);
      finder = find.text(AUDIO_NONE).last;
      await tester.tap(finder);
      await tester.pump(wait);

      // change colors
      await changeColors(tester);

      await tester.pumpAndSettle();
      takeScreenshot(binding, "5_colors.png");

      await tester.pump(wait * 2);

      // Scroll up.
      await tester.dragUntilVisible(
        find.byKey(Key(PreferencesWidget.keyPreferenceName)),
        find.byKey(Key(PreferencesWidget.keyDrag)),
        const Offset(0, 1250),
      );
      await tester.pump(wait);

      // enter preference name
      String preference1 = "${PreferencesWidget.keyPreference} 1";
      finder = find.byKey(Key(PreferencesWidget.keyPreferenceName));
      expect(finder, findsOneWidget);
      await tester.enterText(finder, preference1);
      await tester.pump(wait * 2);

      // save preference
      finder = find.byKey(Key(preference1));
      expect(finder, findsOneWidget);
      await tester.longPress(finder);
      await tester.pump(wait);

      // tap menu
      finder = find.byKey(Key(PreferencesWidget.keyMenu));
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);

      // tap presets
      finder = find.byKey(const Key(PRESETS_TEXT));
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);

      // tap preset
      finder = find.byKey(const Key(DEFAULT_TEXT));
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);

      // save preset
      String preference2 = "${PreferencesWidget.keyPreference} 2";
      finder = find.byKey(Key(preference2));
      expect(finder, findsOneWidget);
      await tester.longPress(finder);
      await tester.pump(wait);

      // tap preset
      finder = find.byKey(Key(preference1));
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait * 2);

      // tap preset
      finder = find.byKey(Key(preference2));
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait * 2);

      // go back
      await goBack(tester);

      // close the drawer
      await closeDrawer(tester);

      // tap preferences menu
      await testPreferencesMenu(tester, preference1);
      await testPreferencesMenu(tester, preference2);

      await tester.pump(wait);
      envVars += "PREFERENCES_END=${stopwatch.elapsed - wait}\n";
    }

    await tester.pump(wait);
    envVars += "DEMO_END=${stopwatch.elapsed}\n";

    debugPrint("\nVariables for demo.sh script:");
    debugPrint(envVars);

    //await tester.pump(wait * 20);
  });
}
