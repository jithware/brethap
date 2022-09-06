// Common routines shared between brethap and brethap_wear

String getDurationString(Duration duration) {
  String text = duration.toString();
  if (duration.isNegative) {
    text = Duration.zero.toString();
  }
  return text.substring(0, text.indexOf('.'));
}

Duration roundDuration(Duration duration) {
  if (duration.inMilliseconds / 1000 == duration.inSeconds) {
    return duration;
  }
  return Duration(seconds: duration.inSeconds + 1);
}
