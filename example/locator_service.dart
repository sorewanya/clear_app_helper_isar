import 'package:clear_app_helper/core/datasources/default_data.dart';
import 'package:clear_app_helper_isar/core/datasources/default_data.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_community/isar.dart';

final getIt = GetIt.instance;

void init() {
  AbstractDefaultData.defaultGetItSingletons(getIt);
  IsarAbstractDefaultData.defaultIsarGetItSingletons(getIt, 'example_db');

  getIt.registerLazySingleton<List<CollectionSchema<dynamic>>>(
    () => [
      ///add your Schema's, for model IsarTest you mast add:
      ///`IsarTestSchema`
    ],
  );
}
