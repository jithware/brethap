import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:brethap/utils.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/home_widget.dart';
import 'package:brethap/hive_storage.dart';

Future<void> main() async {
  late Box preferences, sessions;
  setUpAll((() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter(Directory.systemTemp.createTempSync().path);
    Hive.registerAdapter(PreferenceAdapter());
    Hive.registerAdapter(SessionAdapter());
    preferences = await Hive.openBox('preferences');
    sessions = await Hive.openBox('sessions');
  }));

  tearDownAll((() async {}));

  group('Home', () {
    setUp(() async {});

    tearDown((() async {}));

    testWidgets('HomeWidget', (WidgetTester tester) async {
      const String APP_VERSION = "1.0.0";
      await tester.pumpWidget(MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeWidget(
            appName: APP_NAME,
            version: APP_VERSION,
            preferences: preferences,
            sessions: sessions,
          )));

      const Duration WAIT = Duration(milliseconds: 500);
      Preference preference = preferences.get(0);
      Duration duration = Duration(seconds: preference.duration),
          totalTime = Duration(),
          inhale = Duration(
              milliseconds: preference.inhale[0] + preference.inhale[1]),
          exhale = Duration(
              milliseconds: preference.exhale[0] + preference.exhale[1]);

      // Verify app name in title bar
      expect(find.text(APP_NAME), findsOneWidget);

      // Open the drawer
      await tester.dragFrom(
          tester.getTopLeft(find.byType(MaterialApp)), Offset(0, 0));
      await tester.pump();

      // Verify app name in drawer header
      expect(find.text(APP_NAME), findsNWidgets(2));

      // Verify preferences
      expect(find.text("Preferences"), findsOneWidget);

      // Verify sessions
      expect(find.text("Sessions"), findsOneWidget);

      // Verify donate
      expect(find.text("Calendar"), findsOneWidget);

      // Verify about
      expect(find.text("About $APP_NAME"), findsOneWidget);

      // Close the drawer
      await tester.flingFrom(
          tester.getTopLeft(find.byType(MaterialApp)), Offset(-100, 0), 100);
      await tester.pump();

      // Verify initial status text
      expect(find.text(PRESS_BUTTON_TEXT), findsOneWidget);

      // Verify initial timer text
      expect(find.text(getDurationString(duration)), findsOneWidget);

      // Press start button
      DateTime start = DateTime.now();
      await tester.tap(find.byType(FloatingActionButton));

      // Wait a bit
      await tester.pump(WAIT);
      totalTime += WAIT;

      // Verify status text
      expect(find.text(INHALE_TEXT), findsOneWidget);

      // Forward ahead to exhale
      await tester.pump(inhale);
      totalTime += inhale;

      // Wait a bit
      await tester.pump(WAIT);
      totalTime += WAIT;

      // Verify status text
      expect(find.text(EXHALE_TEXT), findsOneWidget);

      // Forward ahead to inhale
      await tester.pump(exhale);
      totalTime += exhale;

      // Verify decremented timer text
      duration -= totalTime;
      expect(find.text(getDurationString(duration)), findsOneWidget);

      // Press stop button
      DateTime end = DateTime.now();
      await tester.tap(find.byType(FloatingActionButton));

      // Wait a bit
      await tester.pump(WAIT);

      // Verify reset status text
      expect(find.text(PRESS_BUTTON_TEXT), findsOneWidget);

      // Verify reset timer text
      duration = Duration(seconds: preference.duration);
      expect(find.text(getDurationString(duration)), findsOneWidget);

      // Verify session
      expect(sessions.length, 1);
      Session session = sessions.get(0);
      expect(session.start.difference(start).inSeconds, 0);
      expect(session.end.difference(end).inSeconds, 0);
      expect(session.breaths, 1);
    });
  });
}
