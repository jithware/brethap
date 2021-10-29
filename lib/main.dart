import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:brethap/hive_storage.dart';
import 'package:brethap/home_widget.dart';

Future<void> main() async {
  // Do not debugPrint in release
  bool isInRelease = true;
  assert(() {
    isInRelease = false;
    return true;
  }());
  if (isInRelease) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Initialize Hive
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PreferenceAdapter());
  Hive.registerAdapter(SessionAdapter());

  // Initialize Hive boxes
  Box preferences;
  const String PREFERENCES_BOX = "preferences";
  try {
    preferences = await Hive.openBox(PREFERENCES_BOX);
  } catch (e) {
    // Corrupted or incompatible box
    debugPrint(e.toString());
    await Hive.deleteBoxFromDisk(PREFERENCES_BOX);
    // Try again
    preferences = await Hive.openBox(PREFERENCES_BOX);
  }

  Box sessions;
  const String SESSIONS_BOX = "sessions";
  try {
    sessions = await Hive.openBox(SESSIONS_BOX);
  } catch (e) {
    // Corrupted or incompatible box
    debugPrint(e.toString());
    await Hive.deleteBoxFromDisk(SESSIONS_BOX);
    // Try again
    sessions = await Hive.openBox(SESSIONS_BOX);
  }

  // Initialize package info
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appName = packageInfo.appName;
  String version = "${packageInfo.version}+${packageInfo.buildNumber}";

  runApp(MainWidget(
    appName: appName,
    version: version,
    preferences: preferences,
    sessions: sessions,
  ));
}

class MainWidget extends StatelessWidget {
  MainWidget(
      {Key? key,
      required this.appName,
      required this.version,
      required this.preferences,
      required this.sessions})
      : super(key: key);

  final String appName, version;
  final Box preferences, sessions;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      home: HomeWidget(
          appName: appName,
          version: version,
          preferences: preferences,
          sessions: sessions),
    );
  }
}
