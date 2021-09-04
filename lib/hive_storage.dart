import 'package:hive/hive.dart';

part 'hive_storage.g.dart';

@HiveType(typeId: 0)
class Session extends HiveObject {
  @HiveField(0)
  final DateTime start;
  @HiveField(1)
  late final DateTime end;
  @HiveField(2)
  final int breath;

  Session({required this.start, required this.breath});

  @override
  String toString() {
    return "{start: $start, end: $end, breath: $breath}";
  }
}

@HiveType(typeId: 1)
class Preference extends HiveObject {
  @HiveField(0)
  int duration;
  @HiveField(1)
  int breath;
  @HiveField(2)
  int vibrateDuration;
  @HiveField(3)
  int vibrateBreath;
  @HiveField(4)
  bool speakDuration;
  @HiveField(5)
  bool speakBreath;

  Preference(
      {required this.duration,
      required this.breath,
      required this.vibrateDuration,
      required this.vibrateBreath,
      required this.speakDuration,
      required this.speakBreath});

  void copy(Preference preference) {
    this.duration = preference.duration;
    this.breath = preference.breath;
    this.vibrateDuration = preference.vibrateDuration;
    this.vibrateBreath = preference.vibrateBreath;
    this.speakDuration = preference.speakDuration;
    this.speakBreath = preference.speakBreath;
  }

  @override
  String toString() {
    return "{duration: $duration, breath: $breath, vibrateDuration: $vibrateDuration, vibrateBreath: $vibrateBreath, speakDuration: $speakDuration, speakBreath: $speakBreath}";
  }
}
