#!/bin/bash
# Requires: https://github.com/Genymobile/scrcpy#get-the-app  https://ffmpeg.org/download.html
#
# Run from top level: ./screenshots/demo.sh [device id]

DIR="screenshots/android"
mkdir -p "$DIR"
DEMOMP4="$DIR/demo.mp4"
TMPMP4="$(mktemp).mp4"
ENVFILE="screenshots/.env"
VARS="RUNNING_END|SESSIONS_END|CALENDAR_END|PREFERENCES_END|DEMO_END|HOME_SNAP|INHALE_SNAP|DRAWER_SNAP|PREFERENCES_SNAP|COLORS_SNAP|SESSIONS_SNAP|STATS_SNAP|CALENDAR_SNAP|DURATION_SNAP|PRESET1_SNAP|PRESET2_SNAP|CUSTOM_SNAP|PRESETS_END|CUSTOM_END"

# if device is passed as argument (adb devices)
if [ -n "$1" ]; then
  scrcpy --record "$TMPMP4" --serial "$1" --max-fps 10 --always-on-top &
  flutter test integration_test/demo_test.dart -d "$1" | tee /dev/stderr | grep -P "$VARS" > "$ENVFILE"
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
DIFF="$(( $(date -d "$RECORD_LEN" "+%s%6N") - $(date -d "$DEMO_END" "+%s%6N") ))"
SECS="${DIFF:0:2}.${DIFF:2:6}"
START="$(printf '%02d:%02d:%02f' $(echo -e "$SECS/3600\n$SECS%3600/60\n$SECS%60"| bc))" 
END="$RECORD_LEN"
echo "START:$START END:$END FILE:$DEMOMP4" 
ffmpeg -y -ss "$START" -to "$END" -i "$TMPMP4" -c copy "$DEMOMP4" &>/dev/null
rm "$TMPMP4"
#ffplay -autoexit "$DEMOMP4" &>/dev/null

snap () { 
    echo "START:$START FILE:$PNG" 
    ffmpeg -y -ss "$START" -i $DEMOMP4 -frames:v 1 -q:v 5 "$PNG" &>/dev/null; 
}

if [ -n "$HOME_SNAP" ]; then
  PNG="$DIR/1_home.png"
  START="$HOME_SNAP"
  snap
fi

if [ -n "$INHALE_SNAP" ]; then
  PNG="$DIR/2_inhale.png"
  START="$INHALE_SNAP"
  snap
fi

if [ -n "$DRAWER_SNAP" ]; then
  PNG="$DIR/3_drawer.png"
  START="$DRAWER_SNAP"
  snap
fi

if [ -n "$PREFERENCES_SNAP" ]; then
  PNG="$DIR/4_preferences.png"
  START="$PREFERENCES_SNAP"
  snap
fi

if [ -n "$COLORS_SNAP" ]; then
  PNG="$DIR/5_colors.png"
  START="$COLORS_SNAP"
  snap
fi

if [ -n "$SESSIONS_SNAP" ]; then
  PNG="$DIR/6_sessions.png"
  START="$SESSIONS_SNAP"
  snap
fi

if [ -n "$STATS_SNAP" ]; then
  PNG="$DIR/7_stats.png"
  START="$STATS_SNAP"
  snap
fi

if [ -n "$CALENDAR_SNAP" ]; then
  PNG="$DIR/8_calendar.png"
  START="$CALENDAR_SNAP"
  snap
fi

# Wear specific
if [ -n "$DURATION_SNAP" ]; then
  PNG="$DIR/3_duration.png"
  START="$DURATION_SNAP"
  snap
fi

if [ -n "$PRESET1_SNAP" ]; then
  PNG="$DIR/4_preset.png"
  START="$PRESET1_SNAP"
  snap
fi

if [ -n "$PRESET2_SNAP" ]; then
  PNG="$DIR/5_preset.png"
  START="$PRESET2_SNAP"
  snap
fi

if [ -n "$CUSTOM_SNAP" ]; then
  PNG="$DIR/6_custom.png"
  START="$CUSTOM_SNAP"
  snap
fi

if [ -n "$HOME_SNAP" ]; then
  PNG="$DIR/7_dark.png"
  START="$HOME_SNAP"
  snap
fi

exit 0

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