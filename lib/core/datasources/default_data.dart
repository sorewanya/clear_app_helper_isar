import 'package:clear_app_helper/core/datasources/default_data.dart';
import 'package:clear_app_helper/settings/data/repositories/settings_description_repository.dart';
import 'package:clear_app_helper/settings/data/repositories/settings_repository.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_init.dart';
import 'package:clear_app_helper_isar/core/i18n/isar_i18n.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/settings_description_local_data_sources.dart';
import 'package:clear_app_helper_isar/settings/data/datasource/settings_local_data_sources.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

extension IsarAbstractDefaultData on AbstractDefaultData {
  static void defaultIsarGetItSingletons(GetIt getIt, String dbFileName) {
    getIt
      ..registerLazySingleton<IsarI18n>(IsarI18nRu.new)
      ..registerLazySingleton<IsarInit>(
        () => IsarInit(prefsHelper: getIt(), schemas: getIt(), dbFileName: dbFileName, inspector: kDebugMode),
      )
      ..registerLazySingleton<SettingsRepository>(
        () => SettingsRepository(localDataSource: getIt<SettingsLocalDataSource>(), networkInfo: getIt()),
      )
      ..registerLazySingleton<SettingsDescriptionRepository>(
        () => SettingsDescriptionRepository(
          localDataSource: getIt<SettingsDescriptionLocalDataSource>(),
          networkInfo: getIt(),
        ),
      )
      ..registerLazySingleton<SettingsLocalDataSource>(() => SettingsLocalDataSource(getIt(), getIt()))
      ..registerLazySingleton<SettingsDescriptionLocalDataSource>(
        () => SettingsDescriptionLocalDataSource(getIt(), getIt()),
      );
  }
}
