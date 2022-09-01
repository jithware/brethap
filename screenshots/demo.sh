#!/bin/bash
# Requires: https://github.com/Genymobile/scrcpy#get-the-app  https://ffmpeg.org/download.html

DIR="$(dirname $0)/android"
mkdir -p "$DIR"
DEMOMP4="$DIR/demo.mp4"
TMPMP4="$(mktemp).mp4"
ENVFILE="$(dirname $0)/.env"
VARS="RUNNING_END|SESSIONS_END|CALENDAR_END|PREFERENCES_END|DEMO_END|HOME_SNAP|INHALE_SNAP|DRAWER_SNAP|PREFERENCES_SNAP|COLORS_SNAP|SESSIONS_SNAP|STATS_SNAP|CALENDAR_SNAP"
scrcpy --record "$TMPMP4" --max-fps 10 &
flutter test integration_test/demo_test.dart | tee /dev/stderr | grep -P "$VARS" > "$ENVFILE"

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



echo "Done!"