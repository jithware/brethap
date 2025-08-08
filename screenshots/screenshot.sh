#!/bin/bash
# Requires: https://github.com/Genymobile/scrcpy#get-the-app  https://ffmpeg.org/download.html
#
# Run from top level: ./screenshots/screenshot.sh [-s screen] [-d device_id] 
#
# Produces a screenshot and video 

# spellchecker:disable 

usage() { echo "Usage: $0 [-s screen] [-d device]" 1>&2; exit 1; }
while getopts "d:s:" arg; do
  case $arg in
    d)
      device=${OPTARG}
      echo "Using device ${OPTARG}"
      ;;
    s)
      screen=${OPTARG}
      echo "Running screen ${OPTARG}"
      ;;
    *) # Display help.
      usage
      ;;
  esac
done

if [ -z "$screen" ]; then
    echo "Error: Missing mandatory option -s." >&2
    usage
fi

DIR="screenshots/android"
mkdir -p "$DIR"

SCREENMP4="$DIR/${screen}.mp4"
ENVFILE="screenshots/.env"
VARS="TEST_START|TEST_END"

DEFINES=""
echo "DEFINES=$DEFINES"

if test -f "$SCREENMP4"; then
    rm -v "$SCREENMP4"
fi

TMPMP4="$(mktemp).mp4"

# if device is passed as argument (adb devices)
SERIAL=""
D=""
if [ -n "$device" ]; then
  SERIAL="--serial $device"
  D="-d$device"
fi
SCRCPY="scrcpy --no-audio --record "$TMPMP4" "$SERIAL" --max-fps 10 --always-on-top"
$SCRCPY & flutter drive --no-pub --driver=integration_test/driver.dart --target=integration_test/${screen}_test.dart "$D" "$DEFINES" | tee /dev/stderr | grep -P "$VARS" | sed 's/^[^:]*[:] //' > "$ENVFILE"
if [ $? -eq 1 ]; then
  echo "Flutter execution failed!"
  pkill -kill scrcpy;
  rm "$TMPMP4"
  exit 1
else
  pkill -term scrcpy 
  sleep 3
fi

# trim the end of recording where the application is closing
CUTMP4="$(mktemp).mp4"
TRIM="0.5"
ffmpeg -hide_banner -loglevel error -i $TMPMP4 -ss $TRIM -i $TMPMP4 -c copy -map 1:0 -map 0 -shortest -f nut - | ffmpeg -hide_banner -loglevel error -f nut -i - -map 0 -map -0:0 -c copy $CUTMP4
rm "$TMPMP4"
TMPMP4="$CUTMP4"

source "$ENVFILE"
RECORD_LEN="$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 -sexagesimal $TMPMP4)"
# echo "RECORD_LEN=$RECORD_LEN"
# echo "TEST_START=$TEST_START"
# echo "TEST_END=$TEST_END"
DIFF="$(( $(date -d "$RECORD_LEN" "+%s%6N") - $(date -d "$TEST_END" "+%s%6N") ))"
# echo "DIFF=$DIFF"
DIFFSECS="$(echo "scale=6;${DIFF}/1000000" | bc)"
# echo "DIFFSECS=$DIFFSECS"
START="$(printf '%02d:%02d:%02f' $(echo -e "$DIFFSECS/3600\n$DIFFSECS%3600/60\n$DIFFSECS%60"| bc))" 
END="$RECORD_LEN"
echo "START:$START END:$END FILE:$SCREENMP4" 
ffmpeg -y -ss "$START" -to "$END" -i "$TMPMP4" -c copy "$SCREENMP4" &>/dev/null
rm "$TMPMP4"
# ffplay -autoexit "$SCREENMP4" &>/dev/null

WEBPFILE="$DIR/${screen}.webp"
START="$TEST_START"
END="$TEST_END"
echo "START:$START END:$END FILE:$WEBPFILE" 
ffmpeg -n -ss "$START" -to "$END" -i $SCREENMP4 -vcodec libwebp -filter:v fps=10 -lossless 0 -compression_level 3 -q:v 70 -loop 1 -preset picture -an -vsync 0 "$WEBPFILE" &>/dev/null; 

echo "Done!"