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

Future<void> testPreferencesWidget(
  WidgetTester tester,
) async {
  // Trail Name
  Finder trailName = find.byKey(Key(PreferencesWidget.keyTrailName));
  expect(trailName, findsOneWidget);

  // Drag duration minutes slider
  expect(
      find.textContaining(getDurationString(const Duration(seconds: DURATION))),
      findsOneWidget);
  await tester.drag(
      find.byKey(const Key(DURATION_MINUTES_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.bySemanticsLabel(RegExp("1:00:00")), findsOneWidget);

  // Drag duration seconds slider
  await tester.drag(
      find.byKey(const Key(DURATION_SECONDS_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.bySemanticsLabel(RegExp("1:00:29")), findsOneWidget);

  // Drag vibrate duration slider
  expect(find.textContaining("$VIBRATE_DURATION ms"), findsOneWidget);
  await tester.drag(
      find.byKey(const Key(DURATION_VIBRATE_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("500 ms"), findsOneWidget);

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

  // Drag inhale hold slider
  expect(
      find.textContaining(
          "${(INHALE_HOLD / Duration.millisecondsPerSecond)} s"),
      findsWidgets);
  await tester.drag(
      find.byKey(const Key(INHALE_HOLD_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("5.0 s"), findsWidgets);

  // Drag inhale last slider
  expect(
      find.textContaining(
          "${(INHALE_LAST / Duration.millisecondsPerSecond)} s"),
      findsWidgets);
  await tester.drag(
      find.byKey(const Key(INHALE_LAST_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("5.0 s"), findsWidgets);

  // Inhale audio
  Finder inhaleAudio =
      find.byKey(const Key(INHALE_AUDIO_TEXT), skipOffstage: false);
  await tester.ensureVisible(inhaleAudio);
  await tester.tap(inhaleAudio);
  await tester.pumpAndSettle();
  expect(find.textContaining(AUDIO_NONE), findsWidgets);
  expect(find.textContaining(AUDIO_TONE1), findsWidgets);
  expect(find.textContaining(AUDIO_TONE2), findsWidgets);
  expect(find.textContaining(AUDIO_TONE3), findsWidgets);
  expect(find.textContaining(AUDIO_TONE4), findsWidgets);
  Finder toneNone = find.text(AUDIO_NONE).last;
  await tester.tap(toneNone);
  await tester.pumpAndSettle();

  // Inhale hold audio
  Finder inhaleHoldAudio =
      find.byKey(const Key(INHALE_HOLD_AUDIO_TEXT), skipOffstage: false);
  await tester.ensureVisible(inhaleHoldAudio);
  await tester.tap(inhaleHoldAudio);
  await tester.pumpAndSettle();
  expect(find.textContaining(AUDIO_NONE), findsWidgets);
  expect(find.textContaining(AUDIO_TONE1), findsWidgets);
  expect(find.textContaining(AUDIO_TONE2), findsWidgets);
  expect(find.textContaining(AUDIO_TONE3), findsWidgets);
  expect(find.textContaining(AUDIO_TONE4), findsWidgets);
  toneNone = find.text(AUDIO_NONE).last;
  await tester.tap(toneNone);
  await tester.pumpAndSettle();

  // Drag exhale slider
  Finder exhale = find.byKey(const Key(EXHALE_TEXT), skipOffstage: false);
  await tester.ensureVisible(exhale);
  await tester.pumpAndSettle();
  await tester.drag(exhale, const Offset(0.0, 0.0));
  await tester.pumpAndSettle();

  // Drag exhale hold slider
  expect(
      find.textContaining(
          "${(EXHALE_HOLD / Duration.millisecondsPerSecond)} s"),
      findsWidgets);
  await tester.drag(
      find.byKey(const Key(EXHALE_HOLD_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("5.0 s"), findsWidgets);

  // Drag exhale last slider
  expect(
      find.textContaining(
          "${(EXHALE_LAST / Duration.millisecondsPerSecond)} s"),
      findsWidgets);
  await tester.drag(
      find.byKey(const Key(EXHALE_LAST_TEXT)), const Offset(0.0, 0.0));
  await tester.pumpAndSettle();
  expect(find.textContaining("5.0 s"), findsWidgets);

  // Exhale audio
  Finder exhaleAudio =
      find.byKey(const Key(EXHALE_AUDIO_TEXT), skipOffstage: false);
  await tester.ensureVisible(exhaleAudio);
  await tester.tap(exhaleAudio);
  await tester.pumpAndSettle();
  expect(find.textContaining(AUDIO_NONE), findsWidgets);
  expect(find.textContaining(AUDIO_TONE1), findsWidgets);
  expect(find.textContaining(AUDIO_TONE2), findsWidgets);
  expect(find.textContaining(AUDIO_TONE3), findsWidgets);
  expect(find.textContaining(AUDIO_TONE4), findsWidgets);
  toneNone = find.text(AUDIO_NONE).last;
  await tester.tap(toneNone);
  await tester.pumpAndSettle();

  // Exhale hold audio
  Finder exhaleHoldAudio =
      find.byKey(const Key(EXHALE_HOLD_AUDIO_TEXT), skipOffstage: false);
  await tester.ensureVisible(exhaleHoldAudio);
  await tester.tap(exhaleHoldAudio);
  await tester.pumpAndSettle();
  expect(find.textContaining(AUDIO_NONE), findsWidgets);
  expect(find.textContaining(AUDIO_TONE1), findsWidgets);
  expect(find.textContaining(AUDIO_TONE2), findsWidgets);
  expect(find.textContaining(AUDIO_TONE3), findsWidgets);
  expect(find.textContaining(AUDIO_TONE4), findsWidgets);
  toneNone = find.text(AUDIO_NONE).last;
  await tester.tap(toneNone);
  await tester.pumpAndSettle();

  // Drag vibrate breath slider
  expect(find.textContaining("$VIBRATE_BREATH ms"), findsOneWidget);
  await tester.drag(
    find.byKey(const Key(BREATH_VIBRATE_TEXT)),
    const Offset(0.0, 0.0),
  );
  await tester.pumpAndSettle();
  expect(find.textContaining("500 ms"), findsOneWidget);

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
    find.byKey(Key(PreferencesWidget.keyTrailName)),
    find.byKey(Key(PreferencesWidget.keyDrag)),
    const Offset(0, 1250),
  );
  await tester.pumpAndSettle();

  trailName = find.byKey(Key(PreferencesWidget.keyTrailName));
  expect(trailName, findsOneWidget);

  // Verify saved preferences
  for (int i = 1; i <= SAVED_PREFERENCES; i++) {
    String preference = "Preference $i";
    await tester.enterText(trailName, preference);
    await tester.longPress(find.byKey(Key(preference)));
    await tester.pumpAndSettle();
  }
  for (int i = 1; i <= SAVED_PREFERENCES; i++) {
    String preference = "Preference $i";
    await tester.tap(find.byKey(Key(preference)));
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

  await tapMenu(tester);

  // Verify presets
  Finder presets = find.byKey(const Key(PRESETS_TEXT));
  expect(presets, findsOneWidget);

  // Verify default preset
  await tester.tap(presets);
  await tester.pumpAndSettle();
  Finder defalt = find.textContaining(DEFAULT_TEXT);
  expect(defalt, findsOneWidget);
  await tester.tap(defalt);
  await tester.pumpAndSettle();

  // Verify physiological sigh preset
  await tapMenu(tester);
  await tester.tap(presets);
  await tester.pumpAndSettle();
  Finder physsigh = find.textContaining(PHYS_SIGH_TEXT);
  expect(physsigh, findsOneWidget);
  await tester.tap(physsigh);
  await tester.pumpAndSettle();

  // Verify 4-7-8 preset
  await tapMenu(tester);
  await tester.tap(presets);
  await tester.pumpAndSettle();
  Finder preset478 = find.textContaining(PRESET_478_TEXT);
  expect(preset478, findsOneWidget);
  await tester.tap(preset478);
  await tester.pumpAndSettle();

  // Verify Box preset
  await tapMenu(tester);
  await tester.tap(presets);
  await tester.pumpAndSettle();
  Finder presetBox = find.textContaining(BOX_TEXT);
  expect(presetBox, findsOneWidget);
  await tester.tap(presetBox);
  await tester.pumpAndSettle();

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
