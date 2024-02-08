# Metadata

This directory contains the metadata files for publishing to [F-Droid](https://f-droid.org/docs/All_About_Descriptions_Graphics_and_Screenshots/) with a tagged [release](https://github.com/jithware/brethap/releases/new)[^1] and to Google Play with [fastlane](../../Fastfile). 

[^1]: When drafting a new release for fdroid, be sure to set: `Target: fdroid`

## Merge master into fdroid
```
git checkout master
git pull
git checkout fdroid
git merge --no-ff --no-commit master  # resolve any conflicts here
git push
git checkout master
```

## Update a pull request
```
git fetch origin pull/84/head:pull-84
git checkout pull-84 # make any updates here
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
If submodule not created run:
```
git checkout fdroid
git submodule add -b stable https://github.com/flutter/flutter.git submodules/flutter
```
Update the submodule/flutter repo link:
```
git checkout fdroid
git submodule status
git submodule update --remote
git submodule status
# commit fdroid branch with new link then remove all the flutter source with:
git submodule deinit --force submodules/flutter
```
*This is used only for creating a link to the flutter stable repo at a specific commit in time. The actual flutter source code is not used here, only when building on fdroid. It may be necessary to remove and re-add the submodule with:*
```
git rm -f submodules/flutter
git submodule add -b stable --force https://github.com/flutter/flutter.git submodules/flutter
```

## Refresh fdroiddata fork on gitlab
If upstream not already defined (check with: `git remote show upstream` ), run on fdroiddata fork:
```
git remote add upstream https://gitlab.com/fdroid/fdroiddata.git
```
Refresh fork on gitlab:
```
git checkout master
git branch -d com.jithware.brethap
git fetch upstream
git pull upstream master
git push origin master
```

## Build fdroiddata on gitlab
Follow steps in [CONTRIBUTING.md](https://gitlab.com/fdroid/fdroiddata/blob/master/CONTRIBUTING.md#building-it)
