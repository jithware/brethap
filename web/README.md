# Web 

## Deployment to github

First configure the ```/docs``` publishing source on [github](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#choosing-a-publishing-source)

Build the web source:
```
flutter build web
```
 For more information see [flutter web deployment](https://flutter.dev/docs/deployment/web)

Copy files from ```build/web``` directory to the ```docs``` directory:
```
cp -avr build/web/* docs/
```
 Commit changes to github
