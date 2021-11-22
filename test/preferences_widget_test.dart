import 'dart:io';
import 'package:brethap/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:brethap/constants.dart';
import 'package:brethap/preferences_widget.dart';
import 'package:brethap/hive_storage.dart';

Future<void> main() async {
  late Box preferences;
  setUpAll((() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter(Directory.systemTemp.createTempSync().path);
    Hive.registerAdapter(PreferenceAdapter());
    preferences = await Hive.openBox('preferences');
  }));

  tearDownAll((() async {}));

  group('Preferences', () {
    setUp(() async {});

    tearDown((() async {}));

    void verifyPreferences(Preference pref1, Preference pref2) {
      expect(pref1.duration, pref2.duration);
      expect(pref1.vibrateDuration, pref2.vibrateDuration);
      expect(pref1.durationTts, pref2.durationTts);
      expect(pref1.inhale, pref2.inhale);
      expect(pref1.exhale, pref2.exhale);
      expect(pref1.vibrateBreath, pref2.vibrateBreath);
      expect(pref1.breathTts, pref2.breathTts);
    }

    Future<void> tapMenu(WidgetTester tester) async {
      Finder menu = find.byKey(Key("menu"));
      expect(menu, findsOneWidget);
      await tester.tap(menu);
      await tester.pumpAndSettle();
    }

    testWidgets('PreferencesWidget', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: PreferencesWidget(
        preferences: preferences,
        callback: () {
          debugPrint("callback executed");
        },
      )));

      await tester.pumpAndSettle();

      Preference preference = preferences.get(0);

      // Drag duration minutes slider
      expect(
          find.textContaining(
              "${getDurationString(Duration(seconds: DURATION))}"),
          findsOneWidget);
      await tester.drag(
          find.byKey(Key(DURATION_MINUTES_TEXT)), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(preference.duration, 3600);
      expect(find.bySemanticsLabel(RegExp("1:00:00")), findsOneWidget);

      // Drag duration seconds slider
      await tester.drag(
          find.byKey(Key(DURATION_SECONDS_TEXT)), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(preference.duration, 3629);
      expect(find.bySemanticsLabel(RegExp("1:00:29")), findsOneWidget);

      // Drag vibrate duration slider
      expect(find.textContaining("$VIBRATE_DURATION ms"), findsOneWidget);
      await tester.drag(
          find.byKey(Key(DURATION_VIBRATE_TEXT)), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(preference.vibrateDuration, 500);
      expect(find.textContaining("500 ms"), findsOneWidget);

      // Drag duration tts switch
      expect(preference.durationTts, DURATION_TTS);
      await tester.drag(
          find.byKey(Key(DURATION_TTS_TEXT)), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(preference.durationTts, !DURATION_TTS);

      // Drag inhale slider
      expect(
          find.textContaining("${(INHALE / Duration.millisecondsPerSecond)} s"),
          findsWidgets);
      await tester.drag(find.byKey(Key(INHALE_TEXT)), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(preference.inhale, [7800, INHALE_HOLD, INHALE_LAST]);
      expect(find.textContaining("7.8 s"), findsWidgets);

      // Drag inhale hold slider
      expect(
          find.textContaining(
              "${(INHALE_HOLD / Duration.millisecondsPerSecond)} s"),
          findsWidgets);
      await tester.drag(
          find.byKey(Key(INHALE_HOLD_TEXT)), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(preference.inhale, [7800, 5000, INHALE_LAST]);
      expect(find.textContaining("5.0 s"), findsWidgets);

      // Drag inhale last slider
      expect(
          find.textContaining(
              "${(INHALE_LAST / Duration.millisecondsPerSecond)} s"),
          findsWidgets);
      await tester.drag(
          find.byKey(Key(INHALE_LAST_TEXT)), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(preference.inhale, [7800, 5000, 5000]);
      expect(find.textContaining("5.0 s"), findsWidgets);

      // Drag exhale slider
      await tester
          .ensureVisible(find.byKey(Key(EXHALE_TEXT), skipOffstage: false));
      await tester.pumpAndSettle();
      expect(
          find.textContaining("${(EXHALE / Duration.millisecondsPerSecond)} s"),
          findsWidgets);
      await tester.drag(find.byKey(Key(EXHALE_TEXT)), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(preference.exhale, [7800, EXHALE_HOLD, EXHALE_LAST]);
      expect(find.textContaining("7.8 s"), findsWidgets);

      // Drag exhale hold slider
      expect(
          find.textContaining(
              "${(EXHALE_HOLD / Duration.millisecondsPerSecond)} s"),
          findsWidgets);
      await tester.drag(
          find.byKey(Key(EXHALE_HOLD_TEXT)), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(preference.exhale, [7800, 5000, EXHALE_LAST]);
      expect(find.textContaining("5.0 s"), findsWidgets);

      // Drag exhale last slider
      expect(
          find.textContaining(
              "${(EXHALE_LAST / Duration.millisecondsPerSecond)} s"),
          findsWidgets);
      await tester.drag(
          find.byKey(Key(EXHALE_LAST_TEXT)), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(preference.exhale, [7800, 5000, 5000]);
      expect(find.textContaining("5.0 s"), findsWidgets);

      // Drag vibrate breath slider
      expect(find.textContaining("$VIBRATE_BREATH ms"), findsOneWidget);
      await tester.drag(
        find.byKey(Key(BREATH_VIBRATE_TEXT)),
        const Offset(0.0, 0.0),
      );
      await tester.pumpAndSettle();
      expect(preference.vibrateBreath, 500);
      expect(find.textContaining("500 ms"), findsOneWidget);

      // Drag breath tts switch
      expect(preference.breathTts, BREATH_TTS);
      await tester
          .ensureVisible(find.byKey(Key(BREATH_TTS_TEXT), skipOffstage: false));
      await tester.pumpAndSettle();
      await tester.drag(
          find.byKey(Key(BREATH_TTS_TEXT)), const Offset(0.0, 0.0));
      await tester.pumpAndSettle();
      expect(preference.breathTts, !BREATH_TTS);

      // Verify saved preferences
      for (int i = 1; i <= SAVED_PREFERENCES; i++) {
        // Long press preference button
        await tester.longPress(find.byKey(Key("Preference $i")));
        await tester.pumpAndSettle();

        // Verify preference
        preference = preferences.get(i);
        expect(preference.duration, 3629);
        expect(preference.vibrateDuration, 500);
        expect(preference.durationTts, !DURATION_TTS);
        expect(preference.inhale, [7800, 5000, 5000]);
        expect(preference.exhale, [7800, 5000, 5000]);
        expect(preference.vibrateBreath, 500);
        expect(preference.breathTts, !BREATH_TTS);
      }

      await tapMenu(tester);

      // Verify backup
      Finder backup = find.byKey(Key(BACKUP_TEXT));
      expect(backup, findsOneWidget);
      await tester.tap(backup);
      await tester.pumpAndSettle();
      expect(find.textContaining("$SAVED_PREFERENCES preferences backed up"),
          findsOneWidget);

      await tapMenu(tester);

      // Verify reset all
      Finder resetAll = find.byKey(Key(RESET_ALL_TEXT));
      expect(resetAll, findsOneWidget);
      await tester.tap(resetAll);
      await tester.pumpAndSettle();
      Finder cont = find.byKey(Key(CONTINUE_TEXT));
      expect(cont, findsOneWidget);
      await tester.tap(cont);
      await tester.pumpAndSettle();

      //TODO: Verify preferences reset
      //expect(preferences.length, 1);

      await tapMenu(tester);

      // Verify restore
      Finder restore = find.byKey(Key(RESTORE_TEXT));
      expect(restore, findsOneWidget);
      await tester.tap(restore);
      await tester.pumpAndSettle();
      expect(preferences.length, 5);

      await tapMenu(tester);

      // Verify presets
      Finder presets = find.byKey(Key(PRESETS_TEXT));
      expect(presets, findsOneWidget);

      // Verify default preset
      await tester.tap(presets);
      await tester.pumpAndSettle();
      Finder defalt = find.textContaining(DEFAULT_TEXT);
      expect(defalt, findsOneWidget);
      await tester.tap(defalt);
      await tester.pumpAndSettle();
      verifyPreferences(preferences.get(0), getDefaultPref());

      // Verify physiological sigh preset
      await tapMenu(tester);
      await tester.tap(presets);
      await tester.pumpAndSettle();
      Finder physsigh = find.textContaining(PHYS_SIGH_TEXT);
      expect(physsigh, findsOneWidget);
      await tester.tap(physsigh);
      await tester.pumpAndSettle();
      verifyPreferences(preferences.get(0), getPhysSighPref());

      // Verify 4-7-8 preset
      await tapMenu(tester);
      await tester.tap(presets);
      await tester.pumpAndSettle();
      Finder preset478 = find.textContaining(PRESET_478_TEXT);
      expect(preset478, findsOneWidget);
      await tester.tap(preset478);
      await tester.pumpAndSettle();
      verifyPreferences(preferences.get(0), get478Pref());

      // debugDumpApp();
    });
  });
}
