import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';

import 'package:brethap/hive_storage.dart';
import 'package:brethap/home_widget.dart';
import 'package:brethap/constants.dart';

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

  // Initialize package info
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appName = packageInfo.appName;
  String version = "${packageInfo.version}+${packageInfo.buildNumber}";
  String major = packageInfo.version.split(".")[0];
  String minor = packageInfo.version.split(".")[1];

  // Initialize Hive boxes
  Box preferences;
  String preferencesBox = "preferences.$major.$minor";
  try {
    preferences = await Hive.openBox(preferencesBox);
  } catch (e) {
    // Corrupted or incompatible box
    debugPrint(e.toString());
    await Hive.deleteBoxFromDisk(preferencesBox);
    // Try again
    preferences = await Hive.openBox(preferencesBox);
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

  runApp(MainWidget(
    appName: appName,
    version: version,
    preferences: preferences,
    sessions: sessions,
  ));
}

class MainWidget extends StatelessWidget {
  const MainWidget(
      {super.key,
      required this.appName,
      required this.version,
      required this.preferences,
      required this.sessions});

  final String appName, version;
  final Box preferences, sessions;

  @override
  Widget build(BuildContext context) {
    MaterialColor primaryColor = COLORS_PRIMARY[0] as MaterialColor;
    Color backgroundColor = const Color(COLOR_BACKGROUND);
    if (preferences.isNotEmpty) {
      Preference preference = preferences.getAt(0);
      primaryColor = COLORS_PRIMARY[preference.colors[0]] as MaterialColor;
      backgroundColor = Color(preference.colors[1]);
    }

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primaryColor,
        canvasColor: backgroundColor,
      ),
      darkTheme: ThemeData.dark().copyWith(primaryColor: Colors.blue),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeWidget(
          appName: appName,
          version: version,
          preferences: preferences,
          sessions: sessions),
    );
  }
}
