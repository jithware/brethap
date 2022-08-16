import 'package:brethap/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:brethap/constants.dart';
import 'package:brethap/preferences_widget.dart';
import 'home_widget_test.dart';

const Duration wait = Duration(milliseconds: 500);

Future<void> tapMenu(WidgetTester tester) async {
  Finder menu = find.byKey(Key(PreferencesWidget.keyMenu));
  expect(menu, findsOneWidget);
  await tester.tap(menu);
  await tester.pumpAndSettle();
}

Future<void> testSwitch(WidgetTester tester, String key, bool value) async {
  Finder swit = find.byWidgetPredicate((widget) =>
      widget is Switch && widget.key == Key(key) && widget.value == value);
  expect(swit, findsOneWidget);
  await tester.drag(swit, const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  swit = find.byWidgetPredicate((widget) =>
      widget is Switch && widget.key == Key(key) && widget.value == !value);
  expect(swit, findsOneWidget);
}

Future<void> testAudio(WidgetTester tester, String key) async {
  Finder audio = find.byKey(Key(key), skipOffstage: false);
  await tester.ensureVisible(audio);
  await tester.tap(audio);
  await tester.pumpAndSettle();
  expect(find.textContaining(AUDIO_NONE), findsWidgets);
  expect(find.textContaining(AUDIO_TONE1), findsWidgets);
  expect(find.textContaining(AUDIO_TONE2), findsWidgets);
  expect(find.textContaining(AUDIO_TONE3), findsWidgets);
  expect(find.textContaining(AUDIO_TONE4), findsWidgets);
  Finder none = find.text(AUDIO_NONE).last;
  await tester.tap(none);
  await tester.pumpAndSettle();
  expect(find.textContaining(AUDIO_NONE), findsWidgets);
  await tester.pumpAndSettle();
}

Future<void> testPreset(WidgetTester tester, String preset) async {
  await tapMenu(tester);

  Finder presets = find.byKey(const Key(PRESETS_TEXT));
  expect(presets, findsOneWidget);
  await tester.tap(presets);
  await tester.pumpAndSettle();

  Finder tap = find.textContaining(preset);
  expect(tap, findsOneWidget);
  await tester.tap(tap);
  await tester.pumpAndSettle();
}

Future<void> testPreferencesWidget(
  WidgetTester tester,
) async {
  // Preference Name
  Finder preferenceName = find.byKey(Key(PreferencesWidget.keyPreferenceName));
  expect(preferenceName, findsOneWidget);

  // Drag duration minutes slider
  expect(
      find.textContaining(getDurationString(const Duration(seconds: DURATION))),
      findsOneWidget);
  await tester.drag(
      find.byKey(const Key(DURATION_MINUTES_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(
      find.textContaining(getDurationString(
          Duration(minutes: PreferencesWidget.maxDurationMinutes ~/ 2))),
      findsOneWidget);

  // Drag duration seconds slider
  await tester.drag(
      find.byKey(const Key(DURATION_SECONDS_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(
      find.textContaining(getDurationString(Duration(
          minutes: PreferencesWidget.maxDurationMinutes ~/ 2,
          seconds: PreferencesWidget.maxDurationSeconds ~/ 2))),
      findsOneWidget);

  // Drag vibrate duration slider
  expect(find.textContaining("$VIBRATE_DURATION ms"), findsOneWidget);
  await tester.drag(
      find.byKey(const Key(DURATION_VIBRATE_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("${PreferencesWidget.maxVibration * 10 ~/ 2} ms"),
      findsOneWidget);

  // Drag duration tts switch
  await testSwitch(tester, DURATION_TTS_TEXT, false);

  // Drag inhale slider
  Finder inhaleSlider = find.byKey(const Key(INHALE_TEXT), skipOffstage: false);
  await tester.ensureVisible(inhaleSlider);
  await tester.pumpAndSettle();
  expect(find.textContaining("${(INHALE / Duration.millisecondsPerSecond)} s"),
      findsWidgets);
  await tester.drag(inhaleSlider, const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("7.8 s", skipOffstage: false), findsOneWidget);

  // Drag inhale hold slider
  expect(
      find.textContaining(
          "${(INHALE_HOLD / Duration.millisecondsPerSecond)} s"),
      findsWidgets);
  await tester.drag(
      find.byKey(const Key(INHALE_HOLD_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("${PreferencesWidget.maxHold / 10 / 2} s"),
      findsOneWidget);

  // Drag inhale last slider
  expect(
      find.textContaining(
          "${(INHALE_LAST / Duration.millisecondsPerSecond)} s"),
      findsWidgets);
  await tester.drag(
      find.byKey(const Key(INHALE_LAST_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("${PreferencesWidget.maxHold / 10 / 2} s"),
      findsNWidgets(2));

  // Inhale audio
  await testAudio(tester, INHALE_AUDIO_TEXT);

  // Inhale hold audio
  await testAudio(tester, INHALE_HOLD_AUDIO_TEXT);

  // Drag exhale slider
  Finder exhale = find.byKey(const Key(EXHALE_TEXT), skipOffstage: false);
  await tester.ensureVisible(exhale);
  await tester.pumpAndSettle();
  await tester.drag(exhale, const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("7.8 s", skipOffstage: false), findsOneWidget);

  // Drag exhale hold slider
  expect(
      find.textContaining(
          "${(EXHALE_HOLD / Duration.millisecondsPerSecond)} s"),
      findsWidgets);
  await tester.drag(
      find.byKey(const Key(EXHALE_HOLD_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("${PreferencesWidget.maxHold / 10 / 2} s"),
      findsOneWidget);

  // Drag exhale last slider
  expect(
      find.textContaining(
          "${(EXHALE_LAST / Duration.millisecondsPerSecond)} s"),
      findsWidgets);
  await tester.drag(
      find.byKey(const Key(EXHALE_LAST_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("${PreferencesWidget.maxHold / 10 / 2} s"),
      findsNWidgets(2));

  // Exhale audio
  await testAudio(tester, EXHALE_AUDIO_TEXT);

  // Exhale hold audio
  await testAudio(tester, EXHALE_HOLD_AUDIO_TEXT);

  // Drag vibrate breath slider
  expect(find.textContaining("$VIBRATE_BREATH ms"), findsOneWidget);
  await tester.drag(
    find.byKey(const Key(BREATH_VIBRATE_TEXT)),
    const Offset(0.0, 0.0),
  );
  await tester.pumpAndSettle();
  expect(find.textContaining("${PreferencesWidget.maxVibration * 10 ~/ 2} ms"),
      findsOneWidget);

  // Drag breath tts switch
  await testSwitch(tester, BREATH_TTS_TEXT, false);

  // Verify primary color
  Finder primaryColor = find.byKey(const Key(COLOR_PRIMARY_TEXT));
  await tester.ensureVisible(primaryColor);
  expect(primaryColor, findsOneWidget);
  Offset center = tester.getCenter(primaryColor);
  await tester.tapAt(Offset(center.dx, center.dy - 10));
  await tester.pumpAndSettle();

  // Verify background color
  Finder backgroundColor = find.byKey(const Key(COLOR_BACKGROUND_TEXT));
  expect(backgroundColor, findsOneWidget);
  center = tester.getCenter(backgroundColor);
  await tester.tapAt(Offset(center.dx, center.dy - 10));
  await tester.pumpAndSettle();

  // Scroll up.
  await tester.dragUntilVisible(
    find.byKey(Key(PreferencesWidget.keyPreferenceName)),
    find.byKey(Key(PreferencesWidget.keyDrag)),
    const Offset(0, 1250),
  );
  await tester.pumpAndSettle();

  preferenceName = find.byKey(Key(PreferencesWidget.keyPreferenceName));
  expect(preferenceName, findsOneWidget);

  // Save preferences
  for (int i = 1; i <= SAVED_PREFERENCES; i++) {
    String preference = "Preference $i";
    await tester.enterText(preferenceName, preference);
    await tester.longPress(find.byKey(Key(preference)));
    await tester.pumpAndSettle();
  }
  // Verify saved preferences
  for (int i = 1; i <= SAVED_PREFERENCES; i++) {
    String preference = "Preference $i";
    Finder button = find.byKey(Key(preference));
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.textContaining(preference), findsOneWidget);
  }

  await tapMenu(tester);

  // Verify reset all
  Finder resetAll = find.byKey(const Key(RESET_ALL_TEXT));
  expect(resetAll, findsOneWidget);
  await tester.tap(resetAll);
  await tester.pumpAndSettle();
  Finder cont = find.byKey(const Key(CONTINUE_TEXT));
  expect(cont, findsOneWidget);
  await tester.tap(cont);
  await tester.pumpAndSettle();
  expect(find.textContaining("Preferences reset"), findsOneWidget);

  // Verify default preset
  await testPreset(tester, DEFAULT_TEXT);
  expect(
      find.textContaining(getDurationString(const Duration(seconds: DURATION))),
      findsOneWidget);

  // Verify physiological sigh preset
  await testPreset(tester, PHYS_SIGH_TEXT);
  expect(find.textContaining(PHYS_SIGH_TEXT), findsOneWidget);
  expect(
      find.textContaining(
          getDurationString(const Duration(seconds: DURATION_PS))),
      findsOneWidget);

  // Verify 4-7-8 preset
  await testPreset(tester, PRESET_478_TEXT);
  expect(find.textContaining(PRESET_478_TEXT), findsOneWidget);
  expect(
      find.textContaining(
          getDurationString(const Duration(seconds: DURATION_478))),
      findsOneWidget);

  // Verify Box preset
  await testPreset(tester, BOX_TEXT);
  expect(find.textContaining(BOX_TEXT), findsOneWidget);
  expect(
      find.textContaining(
          getDurationString(const Duration(seconds: DURATION_BOX))),
      findsOneWidget);

  // debugDumpApp();
}

Future<void> main() async {
  late HiveData hiveData;
  setUpAll((() async {
    hiveData = await setupHive();
  }));

  tearDownAll((() async {}));

  testWidgets('PreferencesWidget', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PreferencesWidget(
          preferences: hiveData.preferences,
          callback: () {
            debugPrint("testWidget callback executed");
          },
        )));

    await tester.pumpAndSettle();

    await testPreferencesWidget(tester);
  });
}
