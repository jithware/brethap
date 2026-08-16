import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:brethap/hive_storage.dart';
import 'package:brethap/home_widget.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/l10n/generated/app_localizations.dart';

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

  Box customSounds;
  try {
    customSounds = await Hive.openBox("custom_sounds");
  } catch (e) {
    debugPrint(e.toString());
    await Hive.deleteBoxFromDisk("custom_sounds");
    customSounds = await Hive.openBox("custom_sounds");
  }

  runApp(
    MainWidget(
      appName: appName,
      version: version,
      preferences: preferences,
      sessions: sessions,
      customSounds: customSounds,
    ),
  );
}

class MainWidget extends StatefulWidget {
  const MainWidget({
    super.key,
    required this.appName,
    required this.version,
    required this.preferences,
    required this.sessions,
    required this.customSounds,
  });

  final String appName, version;
  final Box preferences, sessions, customSounds;

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _colorIndex = _getColorIndex();
    widget.preferences.listenable(keys: [0]).addListener(_onPreferenceChanged);
  }

  @override
  void dispose() {
    widget.preferences.listenable(keys: [0]).removeListener(_onPreferenceChanged);
    super.dispose();
  }

  int _getColorIndex() {
    if (widget.preferences.isNotEmpty) {
      Preference preference = widget.preferences.getAt(0);
      return preference.colors[0];
    }
    return 0;
  }

  void _onPreferenceChanged() {
    int newIndex = _getColorIndex();
    if (newIndex != _colorIndex) {
      setState(() {
        _colorIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    MaterialColor primaryColor = COLORS_PRIMARY[_colorIndex] as MaterialColor;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomeWidget(
        appName: widget.appName,
        version: widget.version,
        preferences: widget.preferences,
        sessions: widget.sessions,
        customSounds: widget.customSounds,
      ),
    );
  }
}
