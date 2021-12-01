import 'dart:math';
import 'dart:io';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';

import 'package:brethap/constants.dart';
import 'package:brethap/hive_storage.dart';

String getDurationString(Duration duration) {
  String dur = duration.toString();
  return dur.substring(0, dur.indexOf('.'));
}

Duration roundDuration(Duration duration) {
  if (duration.inMilliseconds / 1000 == duration.inSeconds) {
    return duration;
  }
  return Duration(seconds: duration.inSeconds + 1);
}

Card getSessionCard(Session session, {String dateFormat = DATE_FORMAT}) {
  Duration diff = roundDuration(session.end.difference(session.start));
  return Card(
      child: ListTile(
    onLongPress: () {
      debugPrint("session: ${session.toString()}");
    },
    title: Text(DateFormat(dateFormat).format(session.start)),
    subtitle:
        Text("Duration:${getDurationString(diff)}  Breaths:${session.breaths}"),
  ));
}

// Used for testing
Future<void> createRandomSessions(
    Box sessions, int length, DateTime start, DateTime end) async {
  Random random = Random(DateTime.now().millisecondsSinceEpoch);
  DateTime mockStart, mockEnd;
  Session session;
  List<Session> list = sessions.values.toList().cast<Session>();

  while (list.length < length) {
    mockStart = _mockDate(start, end);
    mockEnd = _mockDate(
        mockStart, mockStart.add(Duration(seconds: random.nextInt(120 * 60))));
    session = Session(start: mockStart);
    session.end = mockEnd;
    session.breaths = (random.nextInt(1000) + 1);
    list.add(session);
  }
  list.sort((a, b) =>
      a.start.millisecondsSinceEpoch.compareTo(b.start.millisecondsSinceEpoch));
  await sessions.clear();
  await sessions.addAll(list);

  debugPrint("sessions: ${sessions.values}");
}

DateTime _mockDate([DateTime? firstMoment, DateTime? secondMoment]) {
  Random random = Random(); //Random(DateTime.now().millisecondsSinceEpoch);
  firstMoment ??= DateTime.fromMillisecondsSinceEpoch(0);
  secondMoment ??= DateTime.now();
  Duration _difference = secondMoment.difference(firstMoment);
  return firstMoment
      .add(Duration(seconds: random.nextInt(_difference.inSeconds + 1)));
}

DateTime firstDateOfWeek(DateTime dateTime) {
  DateTime d = DateTime(dateTime.year, dateTime.month, dateTime.day);
  if (d.weekday == DateTime.sunday) {
    return d;
  }
  return d.subtract(Duration(days: d.weekday));
}

DateTime firstDateOfMonth(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, 1);
}

String getStats(
  List<Session> list,
  DateTime start,
  DateTime end,
) {
  Duration totalDuration = Duration(seconds: 0);
  int totalSessions = 0, totalBreaths = 0;

  list.forEach((item) {
    if ((item.start.compareTo(start) >= 0 && item.end.compareTo(end) <= 0)) {
      Duration diff = roundDuration(item.end.difference(item.start));
      totalDuration += diff;
      totalBreaths += item.breaths;
      totalSessions += 1;
    }
  });

  return "Sessions:$totalSessions Duration:${getDurationString(totalDuration)} Breaths:$totalBreaths";
}

String getStreak(
  List<Session> list,
  DateTime start,
  DateTime end,
) {
  if (list.length == 0) {
    return "Streak:0";
  }
  int streak = 1, runningStreak = 1;
  for (int i = 0; i < list.length - 1; i++) {
    // in start/end range
    if (Jiffy(list[i].start).isAfter(Jiffy(start)) &&
        Jiffy(list[i].end).isBefore(Jiffy(end))) {
      Jiffy first = Jiffy(list[i].start).startOf(Units.DAY);
      Jiffy next = Jiffy(list[i + 1].start).startOf(Units.DAY);
      // before end range
      if (next.isBefore(Jiffy(end))) {
        // not the same day
        if (!first.isSame(next, Units.DAY)) {
          // one day difference
          if (first.diff(next, Units.DAY, true).abs() <= 1) {
            runningStreak++;
          } else {
            runningStreak = 1;
          }
          if (runningStreak > streak) {
            streak = runningStreak;
          }
        }
      }
    }
  }
  return "Streak:$streak";
}

Preference getDefaultPref() {
  Preference preference = Preference(
    duration: DURATION,
    inhale: [INHALE, INHALE_HOLD, INHALE_LAST],
    exhale: [EXHALE, EXHALE_HOLD, EXHALE_LAST],
    vibrateDuration: VIBRATE_DURATION,
    vibrateBreath: VIBRATE_BREATH,
    durationTts: DURATION_TTS,
    breathTts: BREATH_TTS,
    colors: [COLOR_PRIMARY, COLOR_BACKGROUND],
  );
  return preference;
}

Preference getPhysSighPref() {
  Preference preference = getDefaultPref();
  preference.duration = DURATION_PS;
  preference.inhale = [INHALE_PS, INHALE_HOLD_PS, INHALE_LAST_PS];
  preference.exhale[0] = EXHALE_PS;
  return preference;
}

Preference get478Pref() {
  Preference preference = getDefaultPref();
  preference.duration = DURATION_478;
  preference.inhale[0] = INHALE_478;
  preference.inhale[1] = INHALE_HOLD_478;
  preference.exhale[0] = EXHALE_478;
  return preference;
}

Preference getBoxPref() {
  Preference preference = getDefaultPref();
  preference.duration = DURATION_BOX;
  preference.inhale[0] = INHALE_BOX;
  preference.inhale[1] = INHALE_HOLD_BOX;
  preference.exhale[0] = EXHALE_BOX;
  preference.exhale[1] = EXHALE_HOLD_BOX;
  return preference;
}

Future<void> createDefaultPref(Box preferences) async {
  Preference preference = getDefaultPref();
  await preferences.add(preference);

  debugPrint("created default preference: $preference");
}

showAlertDialog(BuildContext context, String title, String content, callback) {
  Widget cancelButton = TextButton(
    child: Text(CANCEL_TEXT, key: Key(CANCEL_TEXT)),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    key: Key(CONTINUE_TEXT),
    child: Text(CONTINUE_TEXT),
    onPressed: callback,
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showInfoDialog(BuildContext context, String title, String content) {
  Widget cancelButton = TextButton(
    child: Text(OK_TEXT, key: Key(OK_TEXT)),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      cancelButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<Directory?> getStorageDir() async {
  Directory? directory;
  try {
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadsDirectory();
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  return directory;
}
