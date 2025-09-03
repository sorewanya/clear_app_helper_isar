import 'package:clear_app_helper/core/datasources/db_helper.dart';
import 'package:clear_app_helper/core/domain/entities/app_entity.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_setting_and_stream.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_settings_helper.dart';
import 'package:isar_community/isar.dart';

class IsarHelper<T extends AppEntity> extends DBHelper<T> {
  /// Isar instance. use [IsarInit]
  final Isar isar;
  late final IsarSettingsHelper isarSettingsHelper;

  /// isar schemas, like
  /// ```
  /// isar.isarSettings
  /// ```
  final IsarCollection<T> isarColection;

  IsarSettingAndStream? curentLoggingEnable;
  IsarHelper({required this.isar, required this.isarColection}) {
    isarSettingsHelper = IsarSettingsHelper(isar);
  }

  @override
  bool getCaseSensitiveSettings() {
    return isarSettingsHelper.caseSensitive?.userOrDefaultValue == "true";
  }

  @override
  bool getSearchAddParentToChildListSettings() {
    return isarSettingsHelper.searchAddParentToChildList?.userOrDefaultValue == "true";
  }

  @override
  bool getShowDeletedSettings() {
    return isarSettingsHelper.showDeleted?.userOrDefaultValue == "true";
  }

  @override
  Future<T?> getById({required int id}) {
    return isarColection.get(id);
  }

  @override
  Future<List<int>> addMany({required List<T> itemList}) async {
    return await isar.writeTxn(() async => await isarColection.putAll(itemList));
  }

  @override
  Future<List<int>>? addManyDefault({
    required List<T> Function() itemList,
    int? idToEmptyCheck,
    Function()? doIfAddDefaultsInsideTxn,
  }) {
    if (isarColection.countSync() == 0) {
      return isar.writeTxn(() {
        var r = isarColection.putAll(itemList());
        if (doIfAddDefaultsInsideTxn != null) doIfAddDefaultsInsideTxn();
        return r;
      });
    }
    return null;
  }

  @override
  Future<int> update({required T item}) async {
    return await isar.writeTxn(() async => await isarColection.put(item));
  }

  ///directly delete, not set [isDeleted]!
  @override
  Future<bool> delete(int id) async {
    return await isar.writeTxn(() async => await isarColection.delete(id));
  }

  ///directly delete, not set [isDeleted]!
  @override
  Future<int> deleteMany(List<int> ids) async {
    return await isar.writeTxn(() async => await isarColection.deleteAll(ids));
  }

  ///directly delete, not set [isDeleted]!
  @override
  Future<void> deleteAll() async {
    return await isar.writeTxn(() async => await isarColection.clear());
  }

  @override
  Future<int> add({required T item}) async {
    return await isar.writeTxn(() async => await isarColection.put(item));
  }

  @override
  Stream<T?> watchObject(id) {
    return isarColection.watchObject(id);
  }

  @override
  Stream<void> watchObjectLazy(int? id) {
    if (id == null) {
      return const Stream.empty();
    }
    return isarColection.watchObjectLazy(id);
  }

  @override
  Stream<void> watchLazy() {
    return isarColection.watchLazy();
  }

  static Future<CurentT?> getFromColectionById<CurentT>({
    required IsarCollection<CurentT> isarColection,
    required int id,
  }) async {
    return await isarColection.get(id);
  }
}
