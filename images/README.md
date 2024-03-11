To create qr codes run:

```
qrencode -o github-qr.png "https://github.com/jithware/brethap#brethap"
```

To create animated webp, open animated.xcf in gimp. 

Scale image if desired 
```
Image->Scale Image
Interpolation->Linear
```
Export to webp 
```
File->Export As "animated.webp" 
Export->Lossless, As Animation, Loop forever, Delay 100ms
Export
```

Convert to gray
```
convert launcher-adaptive.png -colorspace gray launcher-monochrome.png 
```

Convert to svg
```
convert -threshold 0% -negate app_icon.png launcher.svg && sed -i 's/fill="#000000"/fill="#1e88e5"/g' launcher.svg
```