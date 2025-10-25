import 'package:clear_app_helper/core/hash_func.dart';
import 'package:clear_app_helper/settings/domain/entities/settings_entity.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/isar/isar_settings_model.dart';
import 'package:isar_community/isar.dart';

class IsarSettingAndStream {
  ///[name] - setting name
  ///
  ///[isar] - Isar instance
  IsarSettingAndStream({required this.name, required this.isar}) {
    setting = isar.isarSettings.getSync(fastHash(name));
    if (setting == null) return;
    _stream = isar.isarSettings.watchObject(setting!.id!);

    _stream?.listen((event) => setting = event);
  }

  final String name;

  ///Isar instance. use [`IsarInit`]
  final Isar isar;

  Stream<SettingsEntity?>? _stream;

  /// current setting from [name]
  SettingsEntity? setting;

  String get userOrDefaultValue => setting?.getUserOrDefaultValueAsString ?? '';
  bool? get userOrDefaultValueAsBool => SettingsBool.fromEntity(setting)?.getUserOrDefaultValueAsBool;
  String? get userOrDefaultValueOrNull => setting?.getUserOrDefaultValueAsString;
}
