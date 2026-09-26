import 'dart:io';
import 'package:brethap/hive_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

const String kTemporaryPath = 'temporaryPath';
const String kApplicationSupportPath = 'applicationSupportPath';
const String kDownloadsPath = 'downloadsPath';
const String kLibraryPath = 'libraryPath';
const String kApplicationDocumentsPath = 'applicationDocumentsPath';
const String kExternalCachePath = 'externalCachePath';
const String kExternalStoragePath = 'externalStoragePath';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return kTemporaryPath;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return kApplicationSupportPath;
  }

  @override
  Future<String?> getLibraryPath() async {
    return kLibraryPath;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return kApplicationDocumentsPath;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return kExternalStoragePath;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return <String>[kExternalCachePath];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>[kExternalStoragePath];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return kDownloadsPath;
  }
}

class HiveData {
  Box preferences, sessions, customSounds;
  HiveData({
    required this.preferences,
    required this.sessions,
    required this.customSounds,
  });
}

Future<HiveData> setupHive() async {
  Box preferences, sessions, customSounds;
  WidgetsFlutterBinding.ensureInitialized();

  PathProviderPlatform.instance = FakePathProviderPlatform();
  await Hive.initFlutter(Directory.systemTemp.createTempSync().path);

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SessionAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(PreferenceAdapter());
  
  preferences = await Hive.openBox('preferences');
  sessions = await Hive.openBox('sessions');
  customSounds = await Hive.openBox('custom_sounds');

  return HiveData(
    preferences: preferences,
    sessions: sessions,
    customSounds: customSounds,
  );
}
