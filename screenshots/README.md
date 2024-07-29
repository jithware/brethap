# Screenshots

To take screenshots, run:
```
flutter screenshot -d <device name> -o screenshots/android/<image>.png
```

To take video, install [scrcpy](https://github.com/Genymobile/scrcpy#get-the-app) and run:
```
scrcpy --record screenshots/android/<video>.mp4 --max-fps 10
```

To convert mp4 to webp, install [ffmpeg](https://ffmpeg.org/download.html) and run:
```
ffmpeg -y -i screenshots/android/<video>.mp4 -vcodec libwebp -filter:v fps=fps=10 -lossless 0 -compression_level 3 -q:v 70 -loop 1 -preset picture -an -vsync 0 screenshots/android/<video>.webp
```

To create feature graphic, run:
```
montage fastlane/metadata/android/en-US/images/phoneScreenshots/[1,4,6,8]*.png -tile x1 -geometry x500+10 -background transparent fastlane/metadata/android/en-US/images/featureGraphic.png && mogrify -gravity Center -crop 1024x500+0+0 fastlane/metadata/android/en-US/images/featureGraphic.png 
```
