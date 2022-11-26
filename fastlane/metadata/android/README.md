# Metadata

This directory contains the metadata files for the F-Droid app store about page. 

For more information see: 

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

## Upgrade flutter for fdroid

### Refresh fdroiddata fork on gitlab
If upstream not already defined (check with `git remote show upstream` ), run on fdroiddata fork:
```
git remote add upstream  https://gitlab.com/fdroid/fdroiddata.git
```
Refresh fork on gitlab:
```
git checkout master
git fetch upstream
git pull upstream master
git push origin master
```

### Upgrage flutter and dependencies
```
flutter upgrade
flutter pub upgrade --major-versions
```
See files in [#67](https://github.com/jithware/brethap/issues/67) to update to flutter version from upgrade above

### Build on fdroiddata
Follow steps in [CONTRIBUTING.md](https://gitlab.com/fdroid/fdroiddata/blob/master/CONTRIBUTING.md#building-it)