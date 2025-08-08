// To execute test run:
// flutter test integration_test/preferences_test.dart

import 'package:brethap/constants.dart';
import 'package:brethap/home_widget.dart';
import 'package:brethap/preferences_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:brethap/main.dart' as app;
import '../test/home_widget_test.dart';
import 'demo_test.dart';
import 'screenshot.dart';

Future<void> testPreferences(
  WidgetTester tester, [
  IntegrationTestWidgetsFlutterBinding? binding,
]) async {
  await tester.pump(demoWait);

  // open drawer
  await openDrawer(tester);
  await tester.pump(demoWait);

  // tap preferences
  await tapItem(tester, HomeWidget.keyPreferences);

  if (binding != null) {
    await tester.pumpAndSettle();
    takeScreenshot(binding, "4_preferences.png");
  }

  // drag minutes
  int drag = 20;
  Duration duration = Duration(milliseconds: drag * 10);
  Finder finder = find.byKey(const Key(DURATION_MINUTES_TEXT));
  expect(finder, findsOneWidget);
  Offset topLeft = tester.getTopLeft(finder);
  await tester.timedDragFrom(
    Offset(topLeft.dx + 20, topLeft.dy + 20),
    Offset(drag.toDouble(), 0),
    duration,
  );
  await tester.pump(demoWait);

  // drag seconds
  drag = 90;
  duration = Duration(milliseconds: drag * 10);
  finder = find.byKey(const Key(DURATION_SECONDS_TEXT));
  expect(finder, findsOneWidget);
  topLeft = tester.getTopLeft(finder);
  await tester.timedDragFrom(
    Offset(topLeft.dx + 20, topLeft.dy + 20),
    Offset(drag.toDouble(), 0),
    duration,
  );
  await tester.pump(demoWait);

  // tap tts
  finder = find.byKey(const Key(DURATION_TTS_TEXT));
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(demoWait);

  // tap inhale audio
  finder = find.byKey(const Key(INHALE_AUDIO_TEXT), skipOffstage: false);
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pump(demoWait);
  await tester.tap(finder);
  await tester.pump(demoWait);
  finder = find.text(AUDIO_NONE).last;
  await tester.tap(finder);
  await tester.pump(demoWait);

  await tester.pump(demoWait * 2);

  // Scroll up.
  await tester.dragUntilVisible(
    find.byKey(Key(PreferencesWidget.keyPreferenceName)),
    find.byKey(Key(PreferencesWidget.keyDrag)),
    const Offset(0, 1250),
  );
  await tester.pump(demoWait);

  // enter preference name
  String preference1 = "${PreferencesWidget.keyPreference} 1";
  finder = find.byKey(Key(PreferencesWidget.keyPreferenceName));
  expect(finder, findsOneWidget);
  await tester.enterText(finder, preference1);
  await tester.pump(demoWait * 2);

  // save preference
  finder = find.byKey(Key(preference1));
  expect(finder, findsOneWidget);
  await tester.longPress(finder);
  await tester.pump(demoWait);

  // tap menu
  finder = find.byKey(Key(PreferencesWidget.keyMenu));
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(demoWait);

  // tap presets
  finder = find.byKey(const Key(PRESETS_TEXT));
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(demoWait);

  // tap preset
  finder = find.byKey(const Key(DEFAULT_TEXT));
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(demoWait);

  // save preset
  String preference2 = "${PreferencesWidget.keyPreference} 2";
  finder = find.byKey(Key(preference2));
  expect(finder, findsOneWidget);
  await tester.longPress(finder);
  await tester.pump(demoWait);

  // tap preset
  finder = find.byKey(Key(preference1));
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(demoWait * 2);

  // tap preset
  finder = find.byKey(Key(preference2));
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pump(demoWait * 2);

  // go back
  await goBack(tester);

  // close the drawer
  await closeDrawer(tester);

  // tap preferences menu
  await testPreferencesMenu(tester, preference1);
  await testPreferencesMenu(tester, preference2);

  await tester.pump(demoWait);
}

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test Preferences', skip: false, (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle();
    await tester.pump(demoWait);

    String envVars = "";
    Duration startDuration = Duration.zero;
    Stopwatch stopwatch = Stopwatch()..start();

    await testPreferences(tester, binding);

    envVars += "$testStart=$startDuration\n";
    envVars += "$testEnd=${stopwatch.elapsed}\n";
    debugPrint(envVars);
  });
}
