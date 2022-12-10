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