import 'package:clear_app_helper/core/datasources/db_helper.dart';
import 'package:clear_app_helper/core/datasources/local_data_source.dart';
import 'package:clear_app_helper/core/domain/entities/app_entity.dart';
import 'package:clear_app_helper/core/domain/entities/search_entity.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_init.dart';

// ignore: avoid_types_as_parameter_names
abstract class IsarLocalDataSource<Type extends AppEntity, SEType extends SearchEntity>
    extends LocalDataSource<Type, SEType> {
  IsarLocalDataSource(this.isarInit);

  final IsarInit isarInit;
  @override
  Future<int> add(Type item);

  @override
  Future<List<int>> addMany(List<Type> itemList);
  @override
  Future<int> countOfFinded(SEType searchEntity);

  @override
  Future<List<Type>> getAll(SEType searchEntity);
  @override
  Future<List<int>> getAllIds(SEType searchEntity);

  @override
  Future<Type?> getById(int id) async {
    return dbHelper.getById(id: id);
  }

  @override
  Stream<Type?> getStream(int id) {
    return dbHelper.watchObject(id);
  }

  @override
  void setHelpers(DBHelper<Type> dbHelper, [DBLogsHelper? dbLogsHelper]) {
    this.dbHelper = dbHelper;
    this.dbLogsHelper = dbLogsHelper;
  }

  @override
  Future<int> update(Type item);
  @override
  Stream<void> watchLazy() {
    return dbHelper.watchLazy();
  }

  @override
  Stream<void> watchObjectLazy(int? id) {
    return dbHelper.watchObjectLazy(id);
  }
}
