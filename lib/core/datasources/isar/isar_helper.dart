import 'package:clear_app_helper/core/datasources/db_helper.dart';
import 'package:clear_app_helper/core/domain/entities/app_entity.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_setting_and_stream.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_settings_helper.dart';
import 'package:isar_community/isar.dart';

class IsarHelper<T extends AppEntity> extends DBHelper<T> {
  IsarHelper({required this.isar, required this.isarCollection}) {
    isarSettingsHelper = IsarSettingsHelper(isar);
  }

  /// Isar instance. use [`IsarInit`]
  final Isar isar;

  late final IsarSettingsHelper isarSettingsHelper;

  /// isar schemas, like
  /// ```
  /// isar.isarSettings
  /// ```
  final IsarCollection<T> isarCollection;
  IsarSettingAndStream? currentLoggingEnable;

  @override
  Future<int> add({required T item}) async {
    return isar.writeTxn(() async => isarCollection.put(item));
  }

  @override
  Future<List<int>> addMany({required List<T> itemList}) async {
    return isar.writeTxn(() async => isarCollection.putAll(itemList));
  }

  @override
  Future<List<int>>? addManyDefault({
    required List<T> Function() itemList,
    int? idToEmptyCheck,
    Function()? doIfAddDefaultsInsideTxn,
  }) async {
    if (isarCollection.countSync() == 0) {
      return isar.writeTxn(() async {
        final r = await isarCollection.putAll(itemList());
        if (doIfAddDefaultsInsideTxn != null) doIfAddDefaultsInsideTxn();
        return r;
      });
    }
    return [];
  }

  ///directly delete, not set [`isDeleted`]!
  @override
  Future<bool> delete(int id) async {
    return isar.writeTxn(() async => isarCollection.delete(id));
  }

  ///directly delete, not set [`isDeleted`]!
  @override
  Future<void> deleteAll() async {
    return isar.writeTxn(() async => isarCollection.clear());
  }

  ///directly delete, not set [`isDeleted`]!
  @override
  Future<int> deleteMany(List<int> ids) async {
    return isar.writeTxn(() async => isarCollection.deleteAll(ids));
  }

  @override
  Future<T?> getById({required int id}) {
    return isarCollection.get(id);
  }

  @override
  bool getCaseSensitiveSettings() {
    return isarSettingsHelper.caseSensitive?.userOrDefaultValue == 'true';
  }

  @override
  bool getSearchAddParentToChildListSettings() {
    return isarSettingsHelper.searchAddParentToChildList?.userOrDefaultValue == 'true';
  }

  @override
  bool getShowDeletedSettings() {
    return isarSettingsHelper.showDeleted?.userOrDefaultValue == 'true';
  }

  @override
  Future<int> update({required T item}) async {
    return isar.writeTxn(() async => isarCollection.put(item));
  }

  @override
  Stream<void> watchLazy() {
    return isarCollection.watchLazy();
  }

  @override
  Stream<T?> watchObject(int id) {
    return isarCollection.watchObject(id);
  }

  @override
  Stream<void> watchObjectLazy(int? id) {
    if (id == null) {
      return const Stream.empty();
    }
    return isarCollection.watchObjectLazy(id);
  }

  static Future<CurrentT?> getFromCollectionById<CurrentT>({
    required IsarCollection<CurrentT> isarCollection,
    required int id,
  }) async {
    return isarCollection.get(id);
  }
}
