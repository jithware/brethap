#!/bin/bash
# Requires: https://github.com/Genymobile/scrcpy#get-the-app  https://ffmpeg.org/download.html

# Copied from log output of demo run
RUNNING_END=0:00:20.487143
SESSIONS_END=0:00:33.636169
CALENDAR_END=0:00:47.480229
PREFERENCES_END=0:01:14.415715
DEMO_END=0:01:15.443365

DIR="$(dirname $0)/android"
mkdir -p "$DIR"
DEMO_LEN="$DEMO_END"
DEMO="$DIR/demo.mp4"
TMPFILE="$(mktemp).mp4"
scrcpy --record "$TMPFILE" --max-fps 10 &
flutter test integration_test/demo_test.dart 

if [ $? -eq 1 ]; then
  echo "Flutter demo failed!"
  pkill -kill scrcpy
  rm "$TMPFILE"
  exit 1
fi

pkill scrcpy

RECORD_LEN="$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal $TMPFILE)"
DIFF="$(( $(date -d "$RECORD_LEN" "+%s%6N") - $(date -d "$DEMO_LEN" "+%s%6N") ))"
START="0:00:${DIFF:0:2}.${DIFF:2:6}"
END="$RECORD_LEN"
echo "START:$START END:$END FILE:$DEMO" 
ffmpeg -y -ss "$START" -to "$END" -i "$TMPFILE" -c copy "$DEMO" &>/dev/null
rm "$TMPFILE"
#ffplay -autoexit "$DEMO" &>/dev/null

clip () { 
    echo "START:$START END:$END FILE:$WEBP" 
    ffmpeg -y -ss "$START" -to "$END" -i $DEMO -vcodec libwebp -filter:v fps=10 -lossless 0 -compression_level 3 -q:v 70 -loop 1 -preset picture -an -vsync 0 "$WEBP" &>/dev/null; 
}

END="0:00:00.000000"
if [ -n "$RUNNING_END" ]; then
  WEBP="$DIR/running.webp"
  START="$END"
  END="$RUNNING_END"
  clip
fi

if [ -n "$SESSIONS_END" ]; then
  WEBP="$DIR/sessions.webp"
  START="$END"
  END="$SESSIONS_END"
  clip
fi

if [ -n "$CALENDAR_END" ]; then
  WEBP="$DIR/calendar.webp"
  START="$END"
  END="$CALENDAR_END"
  clip
fi

if [ -n "$PREFERENCES_END" ]; then
  WEBP="$DIR/preferences.webp"
  START="$END"
  END="$PREFERENCES_END"
  clip
fi

echo "Done!"