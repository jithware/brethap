// See https://docs.hivedb.dev/#/custom-objects/generate_adapter
// flutter packages pub run build_runner build --delete-conflicting-outputs

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'constants.dart';

part 'hive_storage.g.dart';

@HiveType(typeId: 0)
class Session extends HiveObject {
  @HiveField(0)
  final DateTime start;
  @HiveField(1)
  late final DateTime end;
  @HiveField(2)
  late int breaths;
  @HiveField(3)
  List<double>? heartrates;

  Session({required this.start});

  factory Session.fromJson(Map<String, dynamic> data) {
    final start = data['start'] as int;
    final end = data['end'] as int;
    final breaths = data['breaths'] as int;
    List<double>? heartrates =
        data['heartrates'] != null ? List.from(data['heartrates']) : null;
    Session session =
        Session(start: DateTime.fromMillisecondsSinceEpoch(start));
    session.end = DateTime.fromMillisecondsSinceEpoch(end);
    session.breaths = breaths;
    session.heartrates = heartrates;
    return session;
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'breaths': breaths,
      'heartrates': heartrates,
    };
  }

  static bool isSession(Map<String, dynamic> message) {
    try {
      Session.fromJson(message);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

@HiveType(typeId: 1)
class Preference extends HiveObject {
  @HiveField(0)
  int duration;
  @HiveField(1)
  List<int> inhale;
  @HiveField(2)
  List<int> exhale;
  @HiveField(3)
  int vibrateDuration;
  @HiveField(4)
  int vibrateBreath;
  @HiveField(5)
  bool durationTts;
  @HiveField(6)
  bool breathTts;
  @HiveField(7)
  List<int> colors;
  @HiveField(8)
  String name;
  @HiveField(9)
  List<String> audio;

  Preference(
      {required this.duration,
      required this.inhale,
      required this.exhale,
      required this.vibrateDuration,
      required this.vibrateBreath,
      required this.durationTts,
      required this.breathTts,
      required this.colors,
      required this.name,
      required this.audio});

  void copy(Preference preference) {
    duration = preference.duration;
    inhale = List.from(preference.inhale);
    exhale = List.from(preference.exhale);
    vibrateDuration = preference.vibrateDuration;
    vibrateBreath = preference.vibrateBreath;
    durationTts = preference.durationTts;
    breathTts = preference.breathTts;
    colors = List.from(preference.colors);
    name = preference.name;
    audio = List.from(preference.audio);
  }

  factory Preference.fromJson(Map<String, dynamic> data) {
    int duration = data['duration'] as int;
    List<int> inhale = List.from(data['inhale']);
    List<int> exhale = List.from(data['exhale']);
    int vibrateDuration = data['vibrateDuration'] as int;
    int vibrateBreath = data['vibrateBreath'] as int;
    bool durationTts = data['durationTts'] as bool;
    bool breathTts = data['breathTts'] as bool;
    List<int> colors = List.from(data['colors']);
    String name = data['name'] as String;
    List<String> audio = List.from(data['audio']);

    return Preference(
        duration: duration,
        inhale: inhale,
        exhale: exhale,
        vibrateDuration: vibrateDuration,
        vibrateBreath: vibrateBreath,
        durationTts: durationTts,
        breathTts: breathTts,
        colors: colors,
        name: name,
        audio: audio);
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'inhale': inhale,
      'exhale': exhale,
      'vibrateDuration': vibrateDuration,
      'vibrateBreath': vibrateBreath,
      'durationTts': durationTts,
      'breathTts': breathTts,
      'colors': colors,
      'name': name,
      'audio': audio,
    };
  }

  static bool isPreference(Map<String, dynamic> message) {
    try {
      Preference.fromJson(message);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Preference getDefaultPref() {
    Preference preference = Preference(
        duration: DURATION,
        inhale: [INHALE, INHALE_HOLD, INHALE_LAST],
        exhale: [EXHALE, EXHALE_HOLD, EXHALE_LAST],
        vibrateDuration: kIsWeb ? 0 : VIBRATE_DURATION,
        vibrateBreath: kIsWeb ? 0 : VIBRATE_BREATH,
        durationTts: DURATION_TTS,
        breathTts: BREATH_TTS,
        colors: [COLOR_PRIMARY, COLOR_BACKGROUND],
        name: "",
        audio: [
          INHALE_AUDIO,
          EXHALE_AUDIO,
          INHALE_HOLD_AUDIO,
          EXHALE_HOLD_AUDIO
        ]);
    return preference;
  }

  static Preference getPhysSighPref() {
    Preference preference = getDefaultPref();
    preference.duration = DURATION_PS;
    preference.inhale = [INHALE_PS, INHALE_HOLD_PS, INHALE_LAST_PS];
    preference.exhale[0] = EXHALE_PS;
    preference.name = PHYS_SIGH_TEXT;
    return preference;
  }

  static Preference get478Pref() {
    Preference preference = getDefaultPref();
    preference.duration = DURATION_478;
    preference.inhale[0] = INHALE_478;
    preference.inhale[1] = INHALE_HOLD_478;
    preference.exhale[0] = EXHALE_478;
    preference.name = PRESET_478_TEXT;
    return preference;
  }

  static Preference getBoxPref() {
    Preference preference = getDefaultPref();
    preference.duration = DURATION_BOX;
    preference.inhale[0] = INHALE_BOX;
    preference.inhale[1] = INHALE_HOLD_BOX;
    preference.exhale[0] = EXHALE_BOX;
    preference.exhale[1] = EXHALE_HOLD_BOX;
    preference.name = BOX_TEXT;
    return preference;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
