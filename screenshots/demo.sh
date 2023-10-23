#!/bin/bash
# Requires: https://github.com/Genymobile/scrcpy#get-the-app  https://ffmpeg.org/download.html
#
# Run from top level: ./screenshots/demo.sh [device id]

DIR="screenshots/android"
mkdir -p "$DIR"
DEMOMP4="$DIR/demo.mp4"
TMPMP4="$(mktemp).mp4"
ENVFILE="screenshots/.env"
VARS="RUNNING_END|SESSIONS_END|CALENDAR_END|PREFERENCES_END|DEMO_END|PRESETS_END|CUSTOM_END"

if test -f "$DEMOMP4"; then
    rm -v "$DEMOMP4"
fi

# if device is passed as argument (adb devices)
if [ -n "$1" ]; then
  scrcpy --record "$TMPMP4" --serial "$1" --max-fps 10 --always-on-top &
  flutter drive --no-pub --driver=integration_test/driver.dart --target=integration_test/demo_test.dart -d "$1" | tee /dev/stderr | grep -P "$VARS" | sed 's/^[^:]*[:] //' > "$ENVFILE"
else
  scrcpy --record "$TMPMP4" --max-fps 10 --always-on-top &
  flutter test integration_test/demo_test.dart | tee /dev/stderr | grep -P "$VARS" > "$ENVFILE"
fi

if [ $? -eq 1 ]; then
  echo "Flutter demo failed!"
  pkill -kill scrcpy;
  rm "$TMPMP4"
  exit 1
else
  pkill -term scrcpy 
  sleep 3
fi

source "$ENVFILE"
RECORD_LEN="$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal $TMPMP4)"
echo "RECORD_LEN=$RECORD_LEN"
echo "DEMO_END=$DEMO_END"
DIFF="$(( $(date -d "$RECORD_LEN" "+%s%6N") - $(date -d "$DEMO_END" "+%s%6N") ))"
echo "DIFF=$DIFF"
SECS="$(echo "scale=6;${DIFF}/1000000" | bc)"
echo "SECS=$SECS"
START="$(printf '%02d:%02d:%02f' $(echo -e "$SECS/3600\n$SECS%3600/60\n$SECS%60"| bc))" 
END="$RECORD_LEN"
echo "START:$START END:$END FILE:$DEMOMP4" 
ffmpeg -y -ss "$START" -to "$END" -i "$TMPMP4" -c copy "$DEMOMP4" &>/dev/null
rm "$TMPMP4"
#ffplay -autoexit "$DEMOMP4" &>/dev/null

clip () { 
    echo "START:$START END:$END FILE:$WEBP" 
    ffmpeg -y -ss "$START" -to "$END" -i $DEMOMP4 -vcodec libwebp -filter:v fps=10 -lossless 0 -compression_level 3 -q:v 70 -loop 1 -preset picture -an -vsync 0 "$WEBP" &>/dev/null; 
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

# Wear specific
if [ -n "$PRESETS_END" ]; then
  WEBP="$DIR/presets.webp"
  START="$END"
  END="$PRESETS_END"
  clip
fi

if [ -n "$CUSTOM_END" ]; then
  WEBP="$DIR/custom.webp"
  START="$END"
  END="$CUSTOM_END"
  clip
fi

echo "Done!"