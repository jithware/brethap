// See https://docs.hivedb.dev/#/custom-objects/generate_adapter
// flutter packages pub run build_runner build --delete-conflicting-outputs

import 'package:hive/hive.dart';

part 'hive_storage.g.dart';

@HiveType(typeId: 0)
class Session extends HiveObject {
  @HiveField(0)
  final DateTime start;
  @HiveField(1)
  late final DateTime end;
  @HiveField(2)
  late int breaths;

  Session({required this.start});

  @override
  String toString() {
    return "{start: $start, end: $end, breaths: $breaths}";
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

  @override
  String toString() {
    return "{name: $name, duration: $duration, inhale: ${inhale.toString()}, exhale: ${exhale.toString()}, vibrateDuration: $vibrateDuration, vibrateBreath: $vibrateBreath, durationTts: $durationTts, breathTts: $breathTts, colors: ${colors.toString()}, audio: ${audio.toString()}";
  }
}
