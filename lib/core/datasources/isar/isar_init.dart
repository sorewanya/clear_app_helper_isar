import 'dart:io';

import 'package:clear_app_helper/shared_preferences.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_settings_helper.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/isar/isar_settings_description_model.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/isar/isar_settings_model.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarInit {
  factory IsarInit({
    required SharedPreferencesHelper prefsHelper,
    required List<CollectionSchema<dynamic>> schemas,
    required String dbFileName,
    bool inspector = false,
    int maxSizeMiB = Isar.defaultMaxSizeMiB,
    bool relaxedDurability = true,
    CompactCondition? compactOnLaunch,
  }) =>
      _instance ??
      IsarInit._internal(
        prefsHelper: prefsHelper,
        schemas: schemas,
        dbFileName: dbFileName,
        inspector: inspector,
        compactOnLaunch: compactOnLaunch,
        maxSizeMiB: maxSizeMiB,
        relaxedDurability: relaxedDurability,
      );
  IsarInit._internal({
    required SharedPreferencesHelper prefsHelper,
    required List<CollectionSchema<dynamic>> schemas,
    required String dbFileName,
    required bool inspector,
    required int maxSizeMiB,
    required bool relaxedDurability,
    required CompactCondition? compactOnLaunch,
  }) : _prefsHelper = prefsHelper,
       _schemas = schemas,
       _dbFileName = dbFileName,
       _inspector = inspector,
       _maxSizeMiB = maxSizeMiB,
       _relaxedDurability = relaxedDurability,
       _compactOnLaunch = compactOnLaunch {
    _instance = this;
  }
  static IsarInit? _instance;
  late final Isar _isar;
  bool _inited = false;
  final SharedPreferencesHelper _prefsHelper;
  final List<CollectionSchema<dynamic>> _schemas;
  final String _dbFileName;
  final bool _inspector;
  final int _maxSizeMiB;

  final bool _relaxedDurability;

  final CompactCondition? _compactOnLaunch;

  bool get inited => _inited;

  Isar get isar {
    if (!_inited) {
      throw StateError('Isar database has not been initialized. Call initialize() first.');
    }
    return _isar;
  }

  Future<void> initialize() async {
    if (_inited) return;

    //TODO todo external storage support
    // final bool useExternalStorage = false;
    // final externalDir = await getExternalStorageDirectory();
    final Directory dir = await getApplicationDocumentsDirectory();
    final String isarDBdirectory = _prefsHelper.getString('isarDBdirectory') ?? '${dir.path}/.isarDB';

    _schemas.addAll([IsarSettingsSchema, IsarSettingsLogSchema, IsarSettingsDescriptionSchema]);

    // Request permission if needed
    // if (useExternalStorage) {
    //   // only if use external storage
    //   final status = await Permission.storage.request();
    //   if (status.isDenied) {
    //     throw Exception("Storage permission denied");
    //   }
    //   isarDBdirectory = '${externalDir?.path}/.isarDB';
    // }

    // Create directory if not exists
    final Directory dbDir = Directory(isarDBdirectory);
    if (!dbDir.existsSync()) {
      await dbDir.create(recursive: true);
    }

    _isar = await Isar.open(
      // Use async open
      _schemas,
      name: _dbFileName,
      inspector: _inspector,
      directory: isarDBdirectory,
      compactOnLaunch: _compactOnLaunch,
      maxSizeMiB: _maxSizeMiB,
      relaxedDurability: _relaxedDurability,
    );
    IsarSettingsHelper(_isar); // Initialize settings helper with the opened Isar instance
    _inited = true; // Set true only after Isar is fully open
  }
}
