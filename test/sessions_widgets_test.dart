import 'package:brethap/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:brethap/utils.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/sessions_widget.dart';
import 'package:brethap/sessions_calendar_widget.dart';
import 'test_utils.dart';

const Duration WAIT = Duration(milliseconds: 500);
int totalSessions = HomeWidget.totalSessions + 1;

Future<void> tapMenu(WidgetTester tester) async {
  Finder menu = find.byKey(Key(SessionsWidget.keyMenu));
  expect(menu, findsOneWidget);
  await tester.tap(menu);
  await tester.pumpAndSettle();
}

Future<void> testSnackBar(WidgetTester tester, Key key, String text) async {
  expect(find.textContaining(text), findsNothing);
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle(WAIT);
  expect(find.textContaining(text), findsOneWidget);
}

Future<void> testStats(WidgetTester tester, String sessions) async {
  String text = "Sessions:$sessions";
  expect(find.textContaining(text), findsNothing);
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle(WAIT);
  expect(find.textContaining(text), findsOneWidget);
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle(WAIT);
}

Future<void> testSessionsWidget(WidgetTester tester) async {
  // Verify menu items

  await tapMenu(tester);

  // Verify clear all
  Finder clearAll = find.byKey(const Key(CLEAR_ALL_TEXT));
  expect(clearAll, findsOneWidget);
  await tester.tap(clearAll);
  await tester.pumpAndSettle();
  Finder cancel = find.byKey(const Key(CANCEL_TEXT));
  expect(cancel, findsOneWidget);
  await tester.tap(cancel);
  await tester.pumpAndSettle();

  await tapMenu(tester);

  // Verify backup
  await testSnackBar(tester, const Key(BACKUP_TEXT), "Sessions backed up");

  await tapMenu(tester);

  // Verify restore
  await testSnackBar(tester, const Key(RESTORE_TEXT), "Sessions restored");

  await tapMenu(tester);

  // Verify export
  await testSnackBar(tester, const Key(EXPORT_TEXT), "Sessions exported");

  // Verify stats
  await testStats(tester, "$totalSessions");
}

Future<void> testSessionsCalendarWidget(WidgetTester tester) async {
  // Verify week/month
  Finder button = find.text('Week');
  expect(button, findsOneWidget);
  await tester.tap(button);
  await tester.pumpAndSettle();
  button = find.text('Month');
  expect(button, findsOneWidget);
  await tester.tap(button);
  await tester.pumpAndSettle();
  button = find.text('Week');
  expect(button, findsOneWidget);

  // Verify stats
  await testStats(tester, "");
}

Future<void> main() async {
  LiveTestWidgetsFlutterBinding();

  late HiveData hiveData;
  setUpAll((() async {
    hiveData = await setupHive();
  }));

  tearDownAll((() async {}));

  group('Sessions Widgets', () {
    late Box sessions;

    setUp(() async {
      sessions = hiveData.sessions;
      await createRandomSessions(
          sessions,
          totalSessions,
          DateTime.now().subtract(const Duration(days: 180)),
          DateTime.now().subtract(const Duration(days: 1)));
    });

    tearDown(() async {
      await sessions.clear();
    });

    testWidgets('SessionsWidget', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SessionsWidget(sessions: sessions),
      ));
      await tester.pump(WAIT);

      await testSessionsWidget(tester);
    });

    testWidgets('SessionsCalendarWidget', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SessionsCalendarWidget(sessions: sessions),
      ));

      await tester.pump(WAIT);

      await testSessionsCalendarWidget(tester);

      //debugDumpApp();
    });
  });
}
