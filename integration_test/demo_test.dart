// To execute test run:
// flutter test integration_test/demo_test.dart

import 'package:brethap/constants.dart';
import 'package:brethap/home_widget.dart';
import 'package:brethap/preferences_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:table_calendar/src/widgets/format_button.dart';

import 'package:brethap/main.dart' as app;

import '../test/home_widget_test.dart';

// ignore_for_file: dead_code
const bool demoRunning = true,
    demoSessions = true,
    demoCalendar = true,
    demoPreferences = true;

const Duration wait = Duration(milliseconds: 500);
const Duration snackbar = Duration(milliseconds: 3500);

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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  testWidgets('Demo', (WidgetTester tester) async {
    await app.main();

    Stopwatch stopwatch = Stopwatch()..start();
    String envVars = "";

    await tester.pump(wait);
    envVars += "HOME_SNAP=${stopwatch.elapsed - wait}\n";

    // Running
    if (demoRunning) {
      debugPrint("Demo Running(${stopwatch.elapsed})...");
      await tester.pump(wait);

      // tap start
      Finder finder = find.byType(FloatingActionButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);

      envVars += "INHALE_SNAP=${stopwatch.elapsed + wait}\n";

      // running
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // tap stop
      finder = find.byType(FloatingActionButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);

      // snack bar close
      await tester.pump(snackbar);

      await tester.pump(wait);

      envVars += "RUNNING_END=${stopwatch.elapsed - wait}\n";
    }

    // Sessions
    if (demoSessions) {
      debugPrint("Demo Sessions(${stopwatch.elapsed})...");
      await tester.pump(wait);

      // open drawer
      await openDrawer(tester);
      envVars += "DRAWER_SNAP=${stopwatch.elapsed - wait}\n";
      await tester.pump(wait);

      // tap sessions
      await tapItem(tester, HomeWidget.keySessions);
      await tester.pump(wait);

      envVars += "SESSIONS_SNAP=${stopwatch.elapsed - wait}\n";

      // tap stats
      await tester.pump(wait);
      Finder finder = find.byType(FloatingActionButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);

      envVars += "STATS_SNAP=${stopwatch.elapsed - wait}\n";

      // snack bar close
      await tester.pump(snackbar);
      await tester.pump(wait);

      // remove session
      Duration duration = const Duration(milliseconds: 500);
      double drag = 500;
      finder = find.byKey(const Key('199'));
      expect(finder, findsOneWidget);
      await tester.timedDrag(finder, Offset(drag, 0), duration);
      await tester.pump(wait * 2);

      // go back
      await goBack(tester);

      // close drawer
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
      await tester.pump(wait);

      envVars += "CALENDAR_SNAP=${stopwatch.elapsed - wait}\n";

      // tap stats
      Finder finder = find.byType(FloatingActionButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait);

      // snack bar close
      await tester.pump(snackbar);
      await tester.pump(wait);

      // tap week
      finder = find.byType(FormatButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait * 2);

      // tap month
      finder = find.byType(FormatButton);
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait * 2);

      // go back
      await goBack(tester);

      // close drawer
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
      await tester.pump(wait);

      envVars += "PREFERENCES_SNAP=${stopwatch.elapsed - wait}\n";

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

      // scroll to primary color
      finder = find.byKey(const Key(COLOR_PRIMARY_TEXT), skipOffstage: false);
      expect(finder, findsOneWidget);
      await tester.ensureVisible(finder);
      await tester.pump(wait);

      // tap primary color
      await tester.pump(wait);
      finder = find.byType(CircleColor);
      expect(finder, findsWidgets);
      await tester.tap(finder.at(5));
      await tester.pump(wait);

      // scroll to background color
      finder = find.byKey(const Key(COLOR_BACKGROUND_TEXT));
      expect(finder, findsOneWidget);
      await tester.ensureVisible(finder);
      await tester.pump(wait);

      // tap background color
      await tester.pump(wait);
      finder = find.byType(CircleColor);
      expect(finder, findsWidgets);
      await tester.tap(finder.at(24));
      await tester.pump(wait);

      // tap shade
      await tester.pump(wait);
      finder = find.byType(CircleColor);
      expect(finder, findsWidgets);
      await tester.tap(finder.at(19));
      await tester.pump(wait);

      // tap back
      await tester.pump(wait);
      finder = find.byIcon(Icons.arrow_back);
      expect(finder, findsWidgets);
      await tester.tap(finder.at(0));
      await tester.pump(wait);

      envVars += "COLORS_SNAP=${stopwatch.elapsed - wait}\n";

      await tester.pump(wait * 2);

      // Scroll up.
      await tester.dragUntilVisible(
        find.byKey(Key(PreferencesWidget.keyPreferenceName)),
        find.byKey(Key(PreferencesWidget.keyDrag)),
        const Offset(0, 1250),
      );
      await tester.pump(wait);

      // enter preference name
      String preference = "${PreferencesWidget.keyPreference} 1";
      finder = find.byKey(Key(PreferencesWidget.keyPreferenceName));
      expect(finder, findsOneWidget);
      await tester.enterText(finder, preference);
      await tester.pump(wait * 2);

      // save preference
      finder = find.byKey(Key(preference));
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
      preference = "${PreferencesWidget.keyPreference} 2";
      finder = find.byKey(Key(preference));
      expect(finder, findsOneWidget);
      await tester.longPress(finder);
      await tester.pump(wait);

      // tap preset
      preference = "${PreferencesWidget.keyPreference} 1";
      finder = find.byKey(Key(preference));
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait * 2);

      // tap preset
      preference = "${PreferencesWidget.keyPreference} 2";
      finder = find.byKey(Key(preference));
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(wait * 2);

      // go back
      await goBack(tester);

      // close drawer
      await closeDrawer(tester);

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
