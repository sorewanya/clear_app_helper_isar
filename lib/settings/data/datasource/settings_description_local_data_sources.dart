import 'package:clear_app_helper/core/hash_func.dart';
import 'package:isar/isar.dart';
import 'package:clear_app_helper/core/datasources/default_data.dart';

import 'package:clear_app_helper_isar/core/datasources/isar/isar_helper.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_local_data_source.dart';
import 'package:clear_app_helper/core/domain/entities/settings_enum.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/isar/isar_settings_description_model.dart';
import 'package:clear_app_helper/settings/domain/entities/search/settings_description_search_entity.dart';
import 'package:clear_app_helper/settings/domain/entities/settings_description_entity.dart';

class SettingsDescriptionLocalDataSource
    extends IsarLocalDataSource<SettingsDescriptionEntity, SettingsDescriptionSearchEntity> {
  AbstractDefaultData defaults;
  final SettingsDefaultData settingsDefaultData = SettingsDefaultData();

  SettingsDescriptionLocalDataSource(super.isarInit, this.defaults) {
    setHelpers(IsarHelper(isar: isarInit.isar, isarColection: isarInit.isar.isarSettingsDescriptions));
    addDefaults();
  }

  void addDefaults() {
    final List<IsarSettingsDescription> list = settingsDefaultData.getDefaultSettingDescriptionList
        .map((e) => IsarSettingsDescription.fromEntity(entity: e))
        .toList();

    defaults.getDefaultSettingDescriptionList.addAll(list);
    dbHelper.addManyDefault(
      itemList: () {
        final itemsNotReseted = list.where(
          (element) => defaults.getDefaultSettingDescriptionList.where((e) => e.id == element.id).isEmpty == true,
        );
        defaults.getDefaultSettingDescriptionList.addAll(itemsNotReseted);
        return defaults.getDefaultSettingDescriptionList;
      },
      idToEmptyCheck: fastHash(CoreSettingsEnum.datetimeDefaultFormat.name),
    );
  }

  QueryBuilder<IsarSettingsDescription, IsarSettingsDescription, QAfterFilterCondition> _filtr(
    SettingsDescriptionSearchEntity searchEntity,
  ) {
    //caseSensitive
    bool caseSensitive = false;
    if (searchEntity.description != null) {
      caseSensitive = dbHelper.getCaseSensitiveSettings();
    }
    return isarInit.isar.isarSettingsDescriptions
        .filter()
        .optional(searchEntity.id != null, (q) => q.idEqualTo(searchEntity.id!))
        .optional(
          searchEntity.description != null,
          (q) => q.descriptionContains(searchEntity.description!, caseSensitive: caseSensitive),
        );
  }

  @override
  Future<List<IsarSettingsDescription>> getAll(SettingsDescriptionSearchEntity searchEntity) async {
    final result = _filtr(searchEntity);
    return await isarInit.isar.txn(() async {
      return await result.findAll();
    });
  }

  @override
  Future<List<int>> getAllIds(SettingsDescriptionSearchEntity searchEntity) async {
    final result = _filtr(searchEntity);
    return await isarInit.isar.txn(() async {
      return await result.idProperty().findAll();
    });
  }

  @override
  Future<int> countOfFinded(SettingsDescriptionSearchEntity searchEntity) async {
    final result = _filtr(searchEntity);
    return await isarInit.isar.txn(() async {
      return result.count();
    });
  }

  @override
  Future<List<int>> addMany(List<SettingsDescriptionEntity> itemList) async {
    return await dbHelper.addMany(itemList: IsarSettingsDescription.fromEntityList(itemList));
  }

  @override
  Future<int> add(SettingsDescriptionEntity item) async {
    return await dbHelper.add(item: IsarSettingsDescription.fromEntity(entity: item));
  }

  @override
  Future<int> update(SettingsDescriptionEntity item) async {
    final itemId = await dbHelper.update(item: IsarSettingsDescription.fromEntity(entity: item));
    return itemId;
  }
}
