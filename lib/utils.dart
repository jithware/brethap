import 'dart:math';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:collection/collection.dart';

import 'package:brethap/constants.dart';
import 'package:brethap/hive_storage.dart';
import 'package:brethap/wear.dart';

Card getSessionCard(context, Session session,
    {String dateFormat = DATE_FORMAT}) {
  Duration diff = roundDuration(session.end.difference(session.start));
  List<double>? heartrates = session.heartrates;
  int average = 0, reduced = 0;
  if (heartrates != null) {
    average = heartrates.average.toInt();
    reduced = (heartrates.last - heartrates.first).toInt();
  }
  return Card(
      child: ListTile(
    onTap: () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    },
    onLongPress: () {
      debugPrint("session: ${session.toString()}");
    },
    title: Text(DateFormat(dateFormat).format(session.start)),
    subtitle: Row(children: [
      Padding(
          padding: const EdgeInsets.all(1.0),
          child: Icon(Icons.timer, color: Theme.of(context).primaryColor)),
      Text(getDurationString(diff)),
      const SizedBox(width: 10.0),
      Padding(
          padding: const EdgeInsets.all(1.0),
          child: Icon(Icons.air, color: Theme.of(context).primaryColor)),
      Text("${session.breaths}"),
      const SizedBox(width: 10.0),
      average > 0
          ? Padding(
              padding: const EdgeInsets.all(1.0),
              child:
                  Icon(Icons.favorite, color: Theme.of(context).primaryColor))
          : const SizedBox.shrink(),
      average > 0 ? Text("$average") : const SizedBox.shrink(),
      const SizedBox(width: 10.0),
      reduced != 0
          ? Padding(
              padding: const EdgeInsets.all(1.0),
              child: Icon(Icons.monitor_heart,
                  color: Theme.of(context).primaryColor))
          : const SizedBox.shrink(),
      reduced != 0 ? Text("$reduced") : const SizedBox.shrink(),
    ]),
  ));
}

// Used for testing
Future<void> createRandomSessions(
    Box sessions, int length, DateTime start, DateTime end) async {
  Random random = Random(DateTime.now().millisecondsSinceEpoch);
  DateTime mockStart, mockEnd;
  Session session;
  List<Session> list = sessions.values.toList().cast<Session>();

  while (list.length < length - 1) {
    mockStart = _mockDate(start, end);
    mockEnd = _mockDate(
        mockStart, mockStart.add(Duration(seconds: random.nextInt(120 * 60))));
    session = Session(start: mockStart);
    session.end = mockEnd;
    int breaths =
        (mockEnd.millisecondsSinceEpoch - mockStart.millisecondsSinceEpoch) ~/
            Duration.millisecondsPerSecond;
    session.breaths = breaths ~/ (random.nextInt(10) + 1);
    list.add(session);
  }

  // Add heartrate session
  if (list.length < length) {
    session =
        Session(start: DateTime.now().subtract(const Duration(minutes: 60)));
    session.end = session.start.add(const Duration(seconds: 60));
    session.breaths = 10;
    session.heartrates = [70, 69, 68, 67, 66, 65, 64, 63, 62, 61, 60];
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
  Duration difference = secondMoment.difference(firstMoment);
  return firstMoment
      .add(Duration(seconds: random.nextInt(difference.inSeconds + 1)));
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
  context,
  List<Session> list,
  DateTime start,
  DateTime end,
) {
  Duration totalDuration = const Duration(seconds: 0);
  int totalSessions = 0, totalBreaths = 0, average = 0;
  List<int> averages = [];

  for (var item in list) {
    if ((item.start.compareTo(start) >= 0 && item.end.compareTo(end) <= 0)) {
      Duration diff = roundDuration(item.end.difference(item.start));
      totalDuration += diff;
      totalBreaths += item.breaths;
      totalSessions += 1;
      if (item.heartrates != null) {
        int avg = item.heartrates!.average.toInt();
        if (avg > 0) {
          averages.add(avg);
        }
      }
    }
  }

  String text =
      "${AppLocalizations.of(context).sessions}:$totalSessions ${AppLocalizations.of(context).duration}:${getDurationString(totalDuration)} ${AppLocalizations.of(context).breaths}:$totalBreaths";

  if (averages.isNotEmpty) {
    average = averages.average.toInt();
    if (average > 0) {
      text += " ${AppLocalizations.of(context).heartrate}:$average";
    }
  }

  return text;
}

String getStreak(
  context,
  List<Session> list,
  DateTime start,
  DateTime end,
) {
  if (list.isEmpty) {
    return "${AppLocalizations.of(context).streak}:0";
  }
  int streak = 1, runningStreak = 1;
  for (int i = 0; i < list.length - 1; i++) {
    // in start/end range
    if (Jiffy.parseFromDateTime(list[i].start)
            .isAfter(Jiffy.parseFromDateTime(start)) &&
        Jiffy.parseFromDateTime(list[i].end)
            .isBefore(Jiffy.parseFromDateTime(end))) {
      Jiffy first = Jiffy.parseFromDateTime(list[i].start).startOf(Unit.day);
      Jiffy next = Jiffy.parseFromDateTime(list[i + 1].start).startOf(Unit.day);
      // before end range
      if (next.isBefore(Jiffy.parseFromDateTime(end))) {
        // not the same day
        if (!first.isSame(next, unit: Unit.day)) {
          // one day difference
          if (first.diff(next, unit: Unit.day, asFloat: true).abs() <= 1) {
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
  return "${AppLocalizations.of(context).streak}:$streak";
}

Future<void> createDefaultPref(Box preferences) async {
  Preference preference = Preference.getDefaultPref();
  await preferences.add(preference);

  debugPrint("created default preference: $preference");
}

showAlertDialog(BuildContext context, String title, String content, callback) {
  Widget cancelButton = TextButton(
    child:
        Text(AppLocalizations.of(context).cancel, key: const Key(CANCEL_TEXT)),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    key: const Key(CONTINUE_TEXT),
    onPressed: callback,
    child: Text(AppLocalizations.of(context).cont),
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
    child: Text(AppLocalizations.of(context).ok, key: const Key(OK_TEXT)),
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

Future<void> play(AudioPlayer player, String audio) async {
  if (audio == AUDIO_TONE1) {
    await player.play(AssetSource('tone1.oga'));
  } else if (audio == AUDIO_TONE2) {
    await player.play(AssetSource('tone2.oga'));
  } else if (audio == AUDIO_TONE3) {
    await player.play(AssetSource('tone3.oga'));
  } else if (audio == AUDIO_TONE4) {
    await player.play(AssetSource('tone4.oga'));
  } else if (audio == AUDIO_SILENCE) {
    await player.play(AssetSource('silence15.oga'));
  }
}

bool isPhone() {
  if (!kIsWeb) {
    return Platform.isAndroid || Platform.isIOS;
  }
  return false;
}

Future<bool> isPhysicalPhone() async {
  if (!isPhone()) {
    return false;
  }
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo info = await deviceInfo.androidInfo;
    return info.isPhysicalDevice;
  }
  if (Platform.isIOS) {
    IosDeviceInfo info = await deviceInfo.iosInfo;
    return info.isPhysicalDevice;
  }

  return false;
}

bool isWeb() {
  return kIsWeb;
}
