import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brethap/constants.dart';
import 'package:brethap/preferences_widget.dart';
import 'package:brethap/wear.dart';
import 'package:brethap/l10n/generated/app_localizations.dart';
import 'test_utils.dart';

const Duration wait = Duration(milliseconds: 500);

Future<void> tapMenu(WidgetTester tester) async {
  Finder menu = find.byKey(Key(PreferencesWidget.keyMenu));
  expect(menu, findsOneWidget);
  await tester.tap(menu);
  await tester.pumpAndSettle();
}

Future<void> testSwitch(WidgetTester tester, String key, bool value) async {
  Finder swit = find.byWidgetPredicate(
    (widget) =>
        (widget is Switch && widget.key == Key(key) && widget.value == value) ||
        (widget is SwitchListTile && widget.key == Key(key) && widget.value == value),
  );
  expect(swit, findsOneWidget);
  await tester.tap(swit);
  await tester.pumpAndSettle();
  swit = find.byWidgetPredicate(
    (widget) =>
        (widget is Switch && widget.key == Key(key) && widget.value == !value) ||
        (widget is SwitchListTile && widget.key == Key(key) && widget.value == !value),
  );
  expect(swit, findsOneWidget);
}

Future<void> testAudio(WidgetTester tester, String key, [String? audio]) async {
  audio ??= AUDIO_TONE1;

  Finder finder = find.byKey(Key(key), skipOffstage: false);
  await tester.dragUntilVisible(
    finder,
    find.byType(ListView).first,
    const Offset(0, -200),
  );
  await tester.pumpAndSettle();
  
  await tester.tap(finder);
  await tester.pumpAndSettle();
  
  Finder itemFinder = find.text(audio).last;
  await tester.tap(itemFinder);
  await tester.pumpAndSettle();

  expect(find.textContaining(audio), findsWidgets);
  await tester.pumpAndSettle();
}

Future<void> tapPreset(WidgetTester tester, String preset) async {
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

Future<void> changeColors(WidgetTester tester) async {
  await tester.pump(wait);
}

Future<void> testPreferencesWidget(WidgetTester tester) async {
  // Preference Name
  Finder preferenceName = find.byKey(Key(PreferencesWidget.keyPreferenceName));
  expect(preferenceName, findsOneWidget);

  // Drag duration minutes slider
  expect(
    find.textContaining(getDurationString(const Duration(seconds: DURATION))),
    findsOneWidget,
  );
  await tester.tap(find.byKey(const Key(DURATION_MINUTES_TEXT)));
  await tester.pumpAndSettle();
  expect(
    find.textContaining(
      getDurationString(
        Duration(minutes: PreferencesWidget.maxDurationMinutes ~/ 2),
      ),
    ),
    findsOneWidget,
  );

  // Drag duration seconds slider
  await tester.tap(find.byKey(const Key(DURATION_SECONDS_TEXT)));
  await tester.pumpAndSettle();
  expect(
    find.textContaining(
      getDurationString(
        Duration(
          minutes: PreferencesWidget.maxDurationMinutes ~/ 2,
          seconds: PreferencesWidget.maxDurationSeconds ~/ 2,
        ),
      ),
    ),
    findsOneWidget,
  );

  // Drag vibrate duration slider
  expect(find.textContaining("$VIBRATE_DURATION ms"), findsOneWidget);
  await tester.tap(find.byKey(const Key(DURATION_VIBRATE_TEXT)));
  await tester.pumpAndSettle();
  expect(
    find.textContaining("${PreferencesWidget.maxVibration * 10 ~/ 2} ms"),
    findsOneWidget,
  );

  // Drag duration tts switch
  await testSwitch(tester, DURATION_TTS_TEXT, false);

  // Drag inhale slider
  Finder inhaleSlider = find.byKey(const Key(INHALE_TEXT), skipOffstage: false);
  await tester.ensureVisible(inhaleSlider);
  await tester.pumpAndSettle();
  expect(
    find.textContaining("${(INHALE / Duration.millisecondsPerSecond)} s"),
    findsWidgets,
  );
  await tester.tap(inhaleSlider);
  await tester.pumpAndSettle();
  expect(
    find.textContaining(
      "${((PreferencesWidget.maxInhale + PreferencesWidget.minBreath) / 10 / 2).toStringAsFixed(1)} s",
      skipOffstage: false,
    ),
    findsOneWidget,
  );

  // Drag inhale hold slider
  expect(
    find.textContaining("${(INHALE_HOLD / Duration.millisecondsPerSecond)} s"),
    findsWidgets,
  );
  await tester.tap(find.byKey(const Key(INHALE_HOLD_TEXT)));
  await tester.pumpAndSettle();
  expect(
    find.textContaining("${PreferencesWidget.maxHold / 10 / 2} s"),
    findsOneWidget,
  );

  // Drag inhale last slider
  expect(
    find.textContaining("${(INHALE_LAST / Duration.millisecondsPerSecond)} s"),
    findsWidgets,
  );
  await tester.tap(find.byKey(const Key(INHALE_LAST_TEXT)));
  await tester.pumpAndSettle();
  expect(
    find.textContaining("${PreferencesWidget.maxHold / 10 / 2} s"),
    findsNWidgets(2),
  );

  // Inhale audio
  await testAudio(tester, INHALE_AUDIO_TEXT, AUDIO_TONE1);

  // Inhale hold audio
  await testAudio(tester, INHALE_HOLD_AUDIO_TEXT, AUDIO_TONE3);

  // Drag exhale slider
  Finder exhale = find.byKey(const Key(EXHALE_TEXT), skipOffstage: false);
  await tester.ensureVisible(exhale);
  await tester.pumpAndSettle();
  await tester.tap(exhale);
  await tester.pumpAndSettle();
  expect(
    find.textContaining(
      "${((PreferencesWidget.maxExhale + PreferencesWidget.minBreath) / 10 / 2).toStringAsFixed(1)} s",
      skipOffstage: false,
    ),
    findsOneWidget,
  );

  // Drag exhale hold slider
  expect(
    find.textContaining("${(EXHALE_HOLD / Duration.millisecondsPerSecond)} s"),
    findsWidgets,
  );
  await tester.tap(find.byKey(const Key(EXHALE_HOLD_TEXT)));
  await tester.pumpAndSettle();
  expect(
    find.textContaining("${PreferencesWidget.maxHold / 10 / 2} s"),
    findsOneWidget,
  );

  // Drag exhale last slider
  expect(
    find.textContaining("${(EXHALE_LAST / Duration.millisecondsPerSecond)} s"),
    findsWidgets,
  );
  await tester.tap(find.byKey(const Key(EXHALE_LAST_TEXT)));
  await tester.pumpAndSettle();
  expect(
    find.textContaining("${PreferencesWidget.maxHold / 10 / 2} s"),
    findsNWidgets(2),
  );

  // Exhale audio
  await testAudio(tester, EXHALE_AUDIO_TEXT, AUDIO_TONE2);

  // Exhale hold audio
  await testAudio(tester, EXHALE_HOLD_AUDIO_TEXT, AUDIO_TONE4);

  // Drag vibrate breath slider
  expect(find.textContaining("$VIBRATE_BREATH ms"), findsOneWidget);
  await tester.tap(find.byKey(const Key(BREATH_VIBRATE_TEXT)));
  await tester.pumpAndSettle();
  expect(
    find.textContaining("${PreferencesWidget.maxVibration * 10 ~/ 2} ms"),
    findsOneWidget,
  );

  // Drag breath tts switch
  await testSwitch(tester, BREATH_TTS_TEXT, false);

  // Scroll up.
  await tester.dragUntilVisible(
    find.byKey(Key(PreferencesWidget.keyPreferenceName)),
    find.byType(ListView).first,
    const Offset(0, 500),
  );
  await tester.pumpAndSettle();
  await tester.pump(wait);

  preferenceName = find.byKey(Key(PreferencesWidget.keyPreferenceName));
  expect(preferenceName, findsOneWidget);

  // Save preferences
  for (int i = 1; i <= SAVED_PREFERENCES; i++) {
    String preference = "Preference $i";
    
    // Scroll to input
    await tester.dragUntilVisible(
      preferenceName,
      find.byType(ListView).first,
      const Offset(0, 500),
    );
    await tester.enterText(preferenceName, preference);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Scroll to grid
    Finder gridButton = find.byKey(Key(preference));
    await tester.dragUntilVisible(
      gridButton,
      find.byType(ListView).first,
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    
    await tester.longPress(gridButton);
    await tester.pumpAndSettle();
  }

  // Verify saved preferences
  for (int i = 1; i <= SAVED_PREFERENCES; i++) {
    String preference = "Preference $i";
    Finder button = find.byKey(Key(preference));
    
    await tester.dragUntilVisible(
      button,
      find.byType(ListView).first,
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    
    // Scroll up to check name
    await tester.dragUntilVisible(
      preferenceName,
      find.byType(ListView).first,
      const Offset(0, 500),
    );
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
  expect(find.byType(SnackBar), findsWidgets);

  // Verify 4-7-8 preset
  await tapPreset(tester, PRESET_478_TEXT);
  expect(find.textContaining(PRESET_478_TEXT), findsOneWidget);
  expect(
    find.textContaining(
      getDurationString(const Duration(seconds: DURATION_478)),
    ),
    findsOneWidget,
  );

  // Verify Box preset
  await tapPreset(tester, BOX_TEXT);
  expect(find.textContaining(BOX_TEXT), findsOneWidget);
  expect(
    find.textContaining(
      getDurationString(const Duration(seconds: DURATION_BOX)),
    ),
    findsOneWidget,
  );

  // Verify physiological sigh preset
  await tapPreset(tester, PHYS_SIGH_TEXT);
  expect(find.textContaining(PHYS_SIGH_TEXT), findsOneWidget);
  expect(
    find.textContaining(
      getDurationString(const Duration(seconds: DURATION_PS)),
    ),
    findsOneWidget,
  );

  // Verify default preset
  await tapPreset(tester, DEFAULT_TEXT);
  expect(
    find.textContaining(getDurationString(const Duration(seconds: DURATION))),
    findsOneWidget,
  );

  // debugDumpApp();
}

Future<void> main() async {
  late HiveData hiveData;
  setUpAll((() async {
    hiveData = await setupHive();
    AudioCache.instance = AudioCache(prefix: "audio/");
  }));

  tearDownAll((() async {}));

  testWidgets('PreferencesWidget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PreferencesWidget(
          preferences: hiveData.preferences,
          customSounds: hiveData.customSounds,
          callback: () {
            debugPrint("testWidget callback executed");
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    await testPreferencesWidget(tester);
  });
}
