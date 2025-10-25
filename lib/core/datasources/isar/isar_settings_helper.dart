import 'package:clear_app_helper/core/domain/entities/settings_enum.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_setting_and_stream.dart';
import 'package:isar_community/isar.dart';

class IsarSettingsHelper {
  factory IsarSettingsHelper(Isar isar) => _instance ?? IsarSettingsHelper._internal(isar);
  IsarSettingsHelper._internal(this._isar) {
    caseSensitive ??= IsarSettingAndStream(name: CoreSettingsEnum.searchCaseSensitive.name, isar: _isar);
    searchAddParentToChildList ??= IsarSettingAndStream(
      name: CoreSettingsEnum.searchAddParentToChildList.name,
      isar: _isar,
    );
    showDeleted ??= IsarSettingAndStream(name: CoreSettingsEnum.showDeleted.name, isar: _isar);
    globalLoggingEnable ??= IsarSettingAndStream(name: CoreSettingsEnum.globalLoggingEnable.name, isar: _isar);
  }

  static IsarSettingsHelper? _instance;
  final Isar _isar;
  IsarSettingAndStream? caseSensitive;
  IsarSettingAndStream? showDeleted;

  IsarSettingAndStream? searchAddParentToChildList;

  IsarSettingAndStream? globalLoggingEnable;
}
