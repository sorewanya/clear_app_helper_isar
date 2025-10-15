import 'package:clear_app_helper/core/datasources/default_data.dart';
import 'package:clear_app_helper/core/domain/entities/settings_enum.dart';
import 'package:clear_app_helper/core/hash_func.dart';
import 'package:clear_app_helper/settings/domain/entities/search/settings_search_entity.dart';
import 'package:clear_app_helper/settings/domain/entities/settings_entity.dart';
import 'package:clear_app_helper/settings/domain/entities/settings_log_action.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_helper.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_local_data_source.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_log_helper.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/isar/isar_settings_model.dart';
import 'package:isar_community/isar.dart';

class SettingsLocalDataSource extends IsarLocalDataSource<SettingsEntity, SettingsSearchEntity> {
  AbstractDefaultData defaults;
  final SettingsDefaultData settingsDefaultData = SettingsDefaultData();

  SettingsLocalDataSource(super.isarInit, this.defaults) {
    setHelpers(
      IsarHelper(isar: isarInit.isar, isarColection: isarInit.isar.isarSettings),
      IsarLogsHelper(
        isar: isarInit.isar,
        isarColection: isarInit.isar.isarSettingsLogs,
        loggingSettings: SettingsSettingsEnum.loggingEnable,
      ),
    );
    addDefaults();
  }

  void addDefaults() {
    dbHelper.addManyDefault(
      itemList: () {
        final itemsNotReseted = settingsDefaultData.getDefaultSettingList
            .map((e) => IsarSettings.fromEntity(entity: e))
            .where((element) => defaults.getDefaultSettingList.where((e) => e.name == element.name).isEmpty);
        defaults.getDefaultSettingList.addAll(itemsNotReseted);
        return defaults.getDefaultSettingList;
      },
      idToEmptyCheck: fastHash(CoreSettingsEnum.showDeleted.name),
    );
  }

  QueryBuilder<IsarSettings, IsarSettings, QAfterFilterCondition> _filtr(SettingsSearchEntity searchEntity) {
    //caseSensitive
    bool caseSensitive = false;
    if (searchEntity.name != null || searchEntity.userValue != null || searchEntity.defaultValue != null) {
      caseSensitive = dbHelper.getCaseSensitiveSettings();
    }
    final showDeleted = dbHelper.getShowDeletedSettings();
    return isarInit.isar.isarSettings
        .filter()
        .optional(searchEntity.id != null, (q) => q.idEqualTo(searchEntity.id!))
        .optional(
          searchEntity.startWithName != null,
          (q) => q.nameStartsWith(searchEntity.startWithName!, caseSensitive: caseSensitive),
        )
        .optional(searchEntity.name != null, (q) => q.nameContains(searchEntity.name!, caseSensitive: caseSensitive))
        .optional(
          searchEntity.defaultValue != null,
          (q) => q.defaultValueContains(searchEntity.defaultValue!, caseSensitive: caseSensitive),
        )
        .optional(
          searchEntity.userValue != null,
          (q) => q.userValueContains(searchEntity.userValue!, caseSensitive: caseSensitive),
        )
        .optional(searchEntity.type != null, (q) => q.typeEqualTo(searchEntity.type!))
        .optional(searchEntity.confirmType != null, (q) => q.confirmTypeEqualTo(searchEntity.confirmType!))
        .optional(
          searchEntity.isDeleted != null && searchEntity.id == null,
          (q) => q.isDeletedEqualTo(searchEntity.isDeleted!),
        )
        .optional(
          searchEntity.isDeleted == null && !showDeleted && searchEntity.id == null,
          (q) => q.isDeletedEqualTo(false),
        )
        .optional(searchEntity.isChanged != null, (q) => q.userValueIsNotNull());
  }

  @override
  Future<List<IsarSettings>> getAll(SettingsSearchEntity searchEntity) async {
    final result = _filtr(searchEntity);
    return isarInit.isar.txn(() async {
      return result.findAll();
    });
  }

  @override
  Future<List<int>> getAllIds(SettingsSearchEntity searchEntity) async {
    final result = _filtr(searchEntity);
    return isarInit.isar.txn(() async {
      return result.idProperty().findAll();
    });
  }

  @override
  Future<int> countOfFinded(SettingsSearchEntity searchEntity) async {
    final result = _filtr(searchEntity);
    return isarInit.isar.txn(() async {
      return result.count();
    });
  }

  @override
  Future<List<int>> addMany(List<SettingsEntity> itemList) async {
    return dbHelper.addMany(itemList: IsarSettings.fromEntityList(itemList));
  }

  @override
  Future<int> add(SettingsEntity item) async {
    return dbHelper.add(item: IsarSettings.fromEntity(entity: item));
  }

  @override
  Future<int> update(SettingsEntity item) async {
    final itemId = await dbHelper.update(item: IsarSettings.fromEntity(entity: item));
    await dbLogsHelper?.addLog(
      item: IsarSettingsLog(itemId: itemId, logAction: SettingsLogAction.updateUserValue, settedValue: item.userValue),
      id: itemId,
    );
    return itemId;
  }

  @override
  Stream<List<SettingsEntity>?> watch(SettingsSearchEntity searchEntity) {
    final result = _filtr(searchEntity);
    return result.watch(fireImmediately: true);
  }
}
