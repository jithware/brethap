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

    void verifyDefault(Preference preference) {
      expect(preference.duration, DURATION);
      expect(
          find.textContaining(
              "${getDurationString(Duration(seconds: DURATION))}"),
          findsOneWidget);
      expect(preference.vibrateDuration, VIBRATE_DURATION);
      expect(find.textContaining("$VIBRATE_DURATION ms"), findsOneWidget);
      expect(preference.speakDuration, SPEAK_DURATION);
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Switch &&
              widget.key == Key(DURATION_SPEAK_TEXT) &&
              widget.value == SPEAK_DURATION),
          findsOneWidget);
      expect(preference.breath, BREATH);
      expect(
          find.textContaining("${(BREATH / Duration.millisecondsPerSecond)} s"),
          findsOneWidget);
      expect(preference.vibrateBreath, VIBRATE_BREATH);
      expect(find.textContaining("$VIBRATE_BREATH ms"), findsOneWidget);
      expect(preference.speakBreath, SPEAK_BREATH);
      expect(
          find.byWidgetPredicate((widget) =>
              widget is Switch &&
              widget.key == Key(BREATH_SPEAK_TEXT) &&
              widget.value == SPEAK_BREATH),
          findsOneWidget);
    }

    testWidgets('PreferencesWidget', (WidgetTester tester) async {
      const Duration WAIT = Duration(milliseconds: 500);

      await tester.pumpWidget(MaterialApp(
          home: PreferencesWidget(
        preferences: preferences,
        callback: () {
          debugPrint("callback executed");
        },
      )));

      await tester.pump(WAIT);

      Preference preference = preferences.get(0);

      // Drag duration slider
      expect(
          find.textContaining(
              "${getDurationString(Duration(seconds: DURATION))}"),
          findsOneWidget);
      await tester.drag(find.byKey(Key(DURATION_TEXT)), const Offset(0.0, 0.0));
      await tester.pump(WAIT);
      expect(preference.duration, 3660);
      expect(find.bySemanticsLabel(RegExp("1:01:00")), findsOneWidget);

      // Drag vibrate duration slider
      expect(find.textContaining("$VIBRATE_DURATION ms"), findsOneWidget);
      await tester.drag(
          find.byKey(Key(DURATION_VIBRATE_TEXT)), const Offset(0.0, 0.0));
      await tester.pump(WAIT);
      expect(preference.vibrateDuration, 500);
      expect(find.textContaining("500 ms"), findsOneWidget);

      // Drag speak duration switch
      expect(preference.speakDuration, SPEAK_DURATION);
      await tester.drag(
          find.byKey(Key(DURATION_SPEAK_TEXT)), const Offset(0.0, 0.0));
      await tester.pump(WAIT);
      expect(preference.speakDuration, !SPEAK_DURATION);

      // Drag breath slider
      expect(
          find.textContaining("${(BREATH / Duration.millisecondsPerSecond)} s"),
          findsOneWidget);
      await tester.drag(find.byKey(Key(BREATH_TEXT)), const Offset(0.0, 0.0));
      await tester.pump(WAIT);
      expect(preference.breath, 10200);
      expect(find.textContaining("10.2 s"), findsOneWidget);

      // Drag vibrate breath slider
      expect(find.textContaining("$VIBRATE_BREATH ms"), findsOneWidget);
      await tester.drag(
          find.byKey(Key(BREATH_VIBRATE_TEXT)), const Offset(0.0, 0.0));
      await tester.pump(WAIT);
      expect(preference.vibrateBreath, 250);
      expect(find.textContaining("250 ms"), findsOneWidget);

      // Drag speak breath switch
      expect(preference.speakBreath, SPEAK_BREATH);
      await tester.drag(
          find.byKey(Key(BREATH_SPEAK_TEXT)), const Offset(0.0, 0.0));
      await tester.pump(WAIT);
      expect(preference.speakBreath, !SPEAK_BREATH);

      // Verify saved preferences
      for (int i = 1; i <= SAVED_PREFERENCES + 1; i++) {
        // Long press preference button
        await tester.longPress(find.byKey(Key("Preference $i")));
        await tester.pump(WAIT);

        // Verify preference
        preference = preferences.get(i);
        expect(preference.duration, 3660);
        expect(preference.vibrateDuration, 500);
        expect(preference.speakDuration, !SPEAK_DURATION);
        expect(preference.breath, 10200);
        expect(preference.vibrateBreath, 250);
        expect(preference.speakBreath, !SPEAK_BREATH);
      }

      // Verify menu items
      Finder menu = find.byKey(Key("menu"));
      expect(menu, findsOneWidget);
      await tester.tap(menu);
      await tester.pumpAndSettle();

      // Verify menu items
      Finder resetAll = find.byKey(Key(RESET_ALL_TEXT));
      expect(resetAll, findsOneWidget);
      Finder backup = find.byKey(Key(BACKUP_TEXT));
      expect(backup, findsOneWidget);
      Finder restore = find.byKey(Key(RESTORE_TEXT));
      expect(restore, findsOneWidget);

      // Verify backup
      await tester.tap(backup);
      await tester.pumpAndSettle();

      menu = find.byKey(Key("menu"));
      expect(menu, findsOneWidget);
      await tester.tap(menu);
      await tester.pumpAndSettle();

      // Verify restore
      await tester.tap(restore);
      await tester.pumpAndSettle();

      menu = find.byKey(Key("menu"));
      expect(menu, findsOneWidget);
      await tester.tap(menu);
      await tester.pumpAndSettle();

      // Verify reset all
      await tester.tap(resetAll);
      await tester.pumpAndSettle();
      Finder cont = find.byKey(Key(CONTINUE_TEXT));
      expect(cont, findsOneWidget);
      await tester.tap(cont);
      await tester.pumpAndSettle();

      // TODO: Verify preference reset
      // debugDumpApp();
    });
  });
}
