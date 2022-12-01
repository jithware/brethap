# Metadata

This directory contains the metadata files for the F-Droid app store about page and when publishing to Google Play with fastlane. 

For more information on fdroid metadata see: 

https://f-droid.org/docs/All_About_Descriptions_Graphics_and_Screenshots/

When drafting a [new release](https://github.com/jithware/brethap/releases/new) for fdroid, be sure to set ```Target: fdroid```

## Merge master into fdroid
```
git checkout master
git pull
git checkout fdroid
git merge --no-ff --no-commit master  # resolve any conflicts here
git push
```

## Upgrade flutter and dependencies
```
git checkout master
flutter upgrade
flutter pub upgrade --major-versions
```
See files in [#67](https://github.com/jithware/brethap/issues/67) to update to flutter version from upgrade above

## Upgrade flutter on fdroid
Need to change the submodule/flutter repo link
```
git checkout fdroid
git rm submodules/flutter
git submodule add -b stable --force https://github.com/flutter/flutter.git submodules/flutter
```

## Refresh fdroiddata fork on gitlab
If upstream not already defined (check with `git remote show upstream` ), run on fdroiddata fork:
```
git remote add upstream https://gitlab.com/fdroid/fdroiddata.git
```
Refresh fork on gitlab:
```
git checkout master
git fetch upstream
git pull upstream master
git push origin master
```

## Build fdroiddata on gitlab
Follow steps in [CONTRIBUTING.md](https://gitlab.com/fdroid/fdroiddata/blob/master/CONTRIBUTING.md#building-it)