import 'dart:io';

import 'package:clear_app_helper/shared_preferences.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_settings_helper.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/isar/isar_settings_description_model.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/isar/isar_settings_model.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class IsarInit {
  static IsarInit? _instance;
  late final Isar _isar;
  bool _inited = false;

  IsarInit._internal({
    required SharedPreferencesHelper prefsHelper,
    required List<CollectionSchema<dynamic>> schemas,
    required String dbFileName,
    required bool inspector,
    required int maxSizeMiB,
    required bool relaxedDurability,
    required CompactCondition? compactOnLaunch,
  }) {
    getApplicationDocumentsDirectory().then((dir) {
      var isarDBdirectory = prefsHelper.prefs.getString('isarDBdirectory') ?? '${dir.path}/.isarDB';
      schemas.addAll([IsarSettingsSchema, IsarSettingsLogSchema, IsarSettingsDescriptionSchema]);

      (Permission.storage.request().isDenied).then((value) {
        if (value == true) throw Exception("Permission.storage.request().isDenied return true");
      });

      ///create dir if not exist
      Directory(isarDBdirectory).create().then((dirCreate) {
        _isar = Isar.openSync(
          schemas,
          name: dbFileName,
          inspector: inspector,
          directory: isarDBdirectory,
          compactOnLaunch: compactOnLaunch,
          maxSizeMiB: maxSizeMiB,
          relaxedDurability: relaxedDurability,
        );
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
  Isar get isar => _isar;
  bool get inited => _inited;
}
