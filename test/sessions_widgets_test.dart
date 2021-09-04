import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:brethap/utils.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/sessions_widget.dart';
import 'package:brethap/sessions_calendar_widget.dart';
import 'package:brethap/hive_storage.dart';

Future<void> main() async {
  setUpAll((() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter(Directory.systemTemp.createTempSync().path);
    Hive.registerAdapter(SessionAdapter());
  }));

  tearDownAll((() async {}));

  group('Sessions', () {
    const int BREATH = 4000;
    Duration totalDuration = Duration();
    int totalBreaths = 0;
    late Box sessions;
    const Duration WAIT = Duration(milliseconds: 500);

    List<DateTime> dates = [];
    const int SESSIONS = 3;
    for (int i = SESSIONS - 1; i >= 0; i--) {
      dates.add(DateTime.now().subtract(Duration(minutes: i + 2)));
      dates.add(DateTime.now().subtract(Duration(minutes: i + 1)));
    }

    setUp(() async {
      sessions = await Hive.openBox("sessions");
      for (int i = 0; i < dates.length; i += 2) {
        Session s = Session(start: dates[i], breath: BREATH);
        s.end = dates[i + 1];
        await sessions.add(s);

        Duration diff = dates[i + 1].difference(dates[i]);
        totalDuration += roundDuration(diff);
        totalBreaths += (roundDuration(diff).inMilliseconds / BREATH).round();
      }
      debugPrint("test sessions: ${sessions.values}");
      debugPrint(
          "test totalDuration:$totalDuration totalBreaths:$totalBreaths");
    });

    tearDown(() async {
      await sessions.clear();
      totalDuration = Duration();
      totalBreaths = 0;
    });

    void expectStats() {
      //debugDumpApp();
      // Verify total sessions text
      expect(find.textContaining("Sessions:$SESSIONS"), findsOneWidget);
      // Verify total duration text
      expect(
          find.textContaining("Duration:${getDurationString(totalDuration)}"),
          findsOneWidget);
      // Verify total breaths text
      expect(find.textContaining("Breaths:$totalBreaths"), findsOneWidget);
      // Verify streak text
      expect(find.textContaining("Streak:1"), findsOneWidget);
    }

    testWidgets('SessionsWidget', (WidgetTester tester) async {
      await tester
          .pumpWidget(MaterialApp(home: SessionsWidget(sessions: sessions)));
      await tester.pump(WAIT);

      // Verify texts
      for (int i = 0; i <= SESSIONS * 2 - 1; i += 2) {
        expect(find.text(DateFormat(DATE_FORMAT).format(dates[i])),
            findsOneWidget);
        Duration diff = roundDuration(dates[i + 1].difference(dates[i]));
        expect(find.textContaining("Duration:${getDurationString(diff)}"),
            findsWidgets);
        int breaths = (diff.inMilliseconds / BREATH).round();
        expect(find.textContaining("Breaths:$breaths"), findsWidgets);
      }

      // Press the button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump(WAIT);

      expectStats();

      // Verify menu items
      Finder menu = find.byKey(Key("menu"));
      expect(menu, findsOneWidget);
      await tester.tap(menu);
      await tester.pumpAndSettle();

      // Verify menu
      Finder clearAll = find.byKey(Key(CLEAR_ALL_TEXT));
      expect(clearAll, findsOneWidget);
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

      // Verify clear all
      await tester.tap(clearAll);
      await tester.pumpAndSettle();
      Finder cont = find.byKey(Key(CONTINUE_TEXT));
      debugPrint("$cont");
      expect(cont, findsOneWidget);
      //await tester.tap(cont);
      await tester.pumpAndSettle();
    });

    testWidgets('SessionsCalendarWidget', (WidgetTester tester) async {
      // get the last session
      DateTime start = dates[dates.length - 2], end = dates[dates.length - 1];
      Duration diff = roundDuration(end.difference(start));
      int breaths = (diff.inMilliseconds / BREATH).round();

      await tester.pumpWidget(
          MaterialApp(home: SessionsCalendarWidget(sessions: sessions)));

      await tester.pump(WAIT);

      // Verify date text
      expect(find.text(DateFormat(DATE_FORMAT).format(start)), findsOneWidget);

      // Verify duration text
      expect(find.textContaining("Duration:${getDurationString(diff)}"),
          findsWidgets);

      // Verify breaths text
      expect(find.textContaining("Breaths:$breaths"), findsWidgets);

      // Press the button
      await tester.tap(find.byType(FloatingActionButton));

      await tester.pump(WAIT);

      expectStats();
    });
  });
}