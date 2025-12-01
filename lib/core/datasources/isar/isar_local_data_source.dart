import 'package:clear_app_helper/core/datasources/db_helper.dart';
import 'package:clear_app_helper/core/datasources/local_data_source.dart';
import 'package:clear_app_helper/core/domain/entities/app_entity.dart';
import 'package:clear_app_helper/core/domain/entities/search_entity.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_init.dart';

abstract class IsarLocalDataSource<T extends AppEntity, SEType extends SearchEntity>
    extends LocalDataSource<T, SEType> {
  IsarLocalDataSource(this.isarInit);

  final IsarInit isarInit;
  @override
  Future<int> add(T item);

  @override
  Future<List<int>> addMany(List<T> itemList);
  @override
  Future<int> countOfFinded(SEType searchEntity);

  @override
  Future<List<T>> getAll(SEType searchEntity);
  @override
  Future<List<int>> getAllIds(SEType searchEntity);

  @override
  Future<T?> getById(int id) async {
    return dbHelper.getById(id: id);
  }

  @override
  Stream<T?> getStream(int id) {
    return dbHelper.watchObject(id);
  }

  @override
  void setHelpers(DBHelper<T> dbHelper, [DBLogsHelper? dbLogsHelper]) {
    this.dbHelper = dbHelper;
    this.dbLogsHelper = dbLogsHelper;
  }

  @override
  Future<int> update(T item);
  @override
  Stream<void> watchLazy() {
    return dbHelper.watchLazy();
  }

  @override
  Stream<void> watchObjectLazy(int? id) {
    return dbHelper.watchObjectLazy(id);
  }
}
