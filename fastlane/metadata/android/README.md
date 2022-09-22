# Metadata

This directory contains the metadata files for the F-Droid app store about page. 

For more information see: 

https://f-droid.org/docs/All_About_Descriptions_Graphics_and_Screenshots/

When drafting a [new release](https://github.com/jithware/brethap/releases/new) for fdroid, be sure to set ```Target: fdroid```

To merge master into fdroid run:
```
git checkout master
git pull
git checkout fdroid
git merge --no-ff --no-commit master  # resolve any conflicts here
git push
```