import 'dart:io';

import 'package:clear_app_helper/shared_preferences.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_settings_helper.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/isar/isar_settings_description_model.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/isar/isar_settings_model.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarInit {
  static IsarInit? _instance;
  late final Isar _isar;
  bool _inited = false;

  IsarInit._internal(SharedPreferencesHelper prefsHelper, List<CollectionSchema<dynamic>> schemas, String dbFileName) {
    getApplicationDocumentsDirectory().then((dir) {
      var isarDBdirectory = prefsHelper.prefs.getString('isarDBdirectory') ?? '${dir.path}/.isarDB';
      schemas.addAll([IsarSettingsSchema, IsarSettingsLogSchema, IsarSettingsDescriptionSchema]);

      ///create dir if not exist
      Directory(isarDBdirectory).create().then((dirCreate) {
        _isar = Isar.openSync(schemas, name: dbFileName, inspector: false, directory: isarDBdirectory);
        IsarSettingsHelper(_isar);
      });
      _inited = true;
      _instance = this;
    });
  }

  factory IsarInit({
    required SharedPreferencesHelper prefsHelper,
    required List<CollectionSchema<dynamic>> schemas,
    required String dbFileName,
  }) => _instance ?? IsarInit._internal(prefsHelper, schemas, dbFileName);
  Isar get isar => _isar;
  bool get inited => _inited;
}
