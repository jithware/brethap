# Web 

## Deployment to Github

### Configure
First configure the ```/docs``` publishing source on [github](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#choosing-a-publishing-source)

### Build 
Build the web source:
```
flutter build web --base-href "/brethap/"
```
 For more information see [flutter web deployment](https://flutter.dev/docs/deployment/web)

### Copy 
Copy files from ```build/web``` directory to the ```docs``` directory (see this feature request https://github.com/flutter/flutter/issues/71130#issuecomment-989776998):
```
cp -avr build/web/* docs/
```

### Commit
Commit and push changes to [github](https://docs.github.com/en/desktop/contributing-and-collaborating-using-github-desktop/making-changes-in-a-branch/pushing-changes-to-github)
