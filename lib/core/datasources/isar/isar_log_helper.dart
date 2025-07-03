import 'package:clear_app_helper/core/datasources/db_helper.dart';
import 'package:clear_app_helper/core/domain/entities/settings_enum.dart';
import 'package:clear_app_helper/settings/domain/entities/enums_of_settings.dart';
import 'package:clear_app_helper/settings/domain/entities/settings_entity.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_log.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_helper.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_setting_and_stream.dart';

class IsarLogsHelper<T extends IsarLog> extends IsarHelper with DBLogsHelper {
  IsarLogsHelper({required super.isar, required super.isarColection, this.loggingSettings});

  final EnumsOfSettings? loggingSettings;
  IsarSettingAndStream? globalLoggingSizeLimitType;
  IsarSettingAndStream? globalLoggingSizeLimitCount;

  @override
  bool isLoggingEnabled() {
    ///Check logging enable in settings
    if (loggingSettings != null) {
      curentLoggingEnable ??= IsarSettingAndStream(name: loggingSettings!.name, isar: isar);
    }
    return curentLoggingEnable?.userOrDefaultValueAsBool ??
        isarSettingsHelper.globalLoggingEnable?.userOrDefaultValueAsBool ??
        false;
  }

  ///firts int? - if "disabled" =null , other as index from ["disabled", "byItem", "byClass"]
  ///
  ///second int?  - count of logs
  @override
  (int? type, int? count) loggingSizeLimited() {
    ///Check logging size limit enable in settings
    globalLoggingSizeLimitType ??= IsarSettingAndStream(
      name: CoreSettingsEnum.globalLoggingSizeLimitType.name,
      isar: isar,
    );
    if (globalLoggingSizeLimitType?.setting == null) {
      return (null, null);
    } else {
      final limit = SettingsValue.fromEntity(globalLoggingSizeLimitType?.setting);
      if (limit?.getUserOrDefaultValueStringOrEmpty == "disabled") return (null, null);
      //0 - no limit
      globalLoggingSizeLimitCount ??= IsarSettingAndStream(
        name: CoreSettingsEnum.globalLoggingSizeLimitCount.name,
        isar: isar,
      );
      return (
        limit?.getUserOrDefaultValueIndexOrZero,
        SettingsInt.fromEntity(globalLoggingSizeLimitCount?.setting)?.getUserOrDefaultValueAsIntOrNull,
      );
    }
  }

  ///  filtredById = isarInit.isar.isarTaskLogs.filter().itemIdEqualTo(id).sortByTimestamp()
  ///  T = IsarTaskLog
  @override
  Future checkAndRemoveByCount(int count, bool byItem, int id) async {
    if (T is! IsarLog) return;
    final isarCount = byItem
        ? (isarColection as dynamic).filter().itemIdEqualTo(id).countSync()
        : isarColection.countSync();
    if (count < isarCount) {
      byItem
          ? await isar.writeTxn(
              () async => await (isarColection as dynamic)
                  .filter()
                  .itemIdEqualTo(id)
                  .sortByTimestamp()
                  .limit(isarCount - count)
                  .deleteAll(),
            )
          : await isar.writeTxn(
              () async =>
                  await (isarColection as dynamic).where().sortByTimestamp().limit(isarCount - count).deleteAll(),
            );
    }
  }

  @override
  Future<int> addLog({required item, required id}) async {
    if (!isLoggingEnabled()) return 0;
    final (type, count) = loggingSizeLimited();
    if (type == null) return 0;
    if (count != null && count != 0) {
      await checkAndRemoveByCount(count, (type == 1) ? true : false, id);
    }
    return await super.add(item: item);
  }
}
