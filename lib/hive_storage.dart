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

  Preference(
      {required this.duration,
      required this.inhale,
      required this.exhale,
      required this.vibrateDuration,
      required this.vibrateBreath,
      required this.durationTts,
      required this.breathTts,
      required this.colors,
      required this.name});

  void copy(Preference preference) {
    this.duration = preference.duration;
    this.inhale = List.from(preference.inhale);
    this.exhale = List.from(preference.exhale);
    this.vibrateDuration = preference.vibrateDuration;
    this.vibrateBreath = preference.vibrateBreath;
    this.durationTts = preference.durationTts;
    this.breathTts = preference.breathTts;
    this.colors = List.from(preference.colors);
    this.name = preference.name;
  }

  @override
  String toString() {
    return "{name: $name, duration: $duration, inhale: ${inhale.toString()}, exhale: ${exhale.toString()}, vibrateDuration: $vibrateDuration, vibrateBreath: $vibrateBreath, durationTts: $durationTts, breathTts: $breathTts, colors: ${colors.toString()}}";
  }
}
