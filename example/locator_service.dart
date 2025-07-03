import 'package:clear_app_helper/settings/data/repositories/settings_description_repository.dart';
import 'package:clear_app_helper/settings/data/repositories/settings_repository.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_init.dart';
import 'package:clear_app_helper_isar/core/i18n/isar_i18n.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/settings_description_local_data_sources.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/settings_local_data_sources.dart';

import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

final getIt = GetIt.instance;

void init() {
  getIt.registerLazySingleton<IsarI18n>(() => IsarI18nRu());
  getIt.registerLazySingleton<IsarInit>(
    () => IsarInit(prefsHelper: getIt(), schemas: getIt(), dbFileName: 'kopotproject'),
  );
  getIt.registerLazySingleton<List<CollectionSchema<dynamic>>>(
    () => [
      ///add your Schema's, for model IsarTest you mast add:
      ///`IsarTestSchema`
    ],
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(localDataSource: getIt<SettingsLocalDataSource>(), networkInfo: getIt()),
  );
  getIt.registerLazySingleton<SettingsDescriptionRepository>(
    () => SettingsDescriptionRepository(
      localDataSource: getIt<SettingsDescriptionLocalDataSource>(),
      networkInfo: getIt(),
    ),
  );
  getIt.registerLazySingleton<SettingsLocalDataSource>(() => SettingsLocalDataSource(getIt(), getIt()));
  getIt.registerLazySingleton<SettingsDescriptionLocalDataSource>(
    () => SettingsDescriptionLocalDataSource(getIt(), getIt()),
  );
}
