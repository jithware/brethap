// For testing in a web browser see https://docs.flutter.dev/cookbook/testing/integration/introduction#5b-web

// Not working at the moment see https://github.com/flutter/flutter/issues/102469#issuecomment-1438433689

// Run: chromedriver --port=4444
// Run: flutter drive --no-pub --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
