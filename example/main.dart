// ignore_for_file: unreachable_from_main, depend_on_referenced_packages, dangling_library_doc_comments, flutter_style_todos

///
/// WARNING!
///
/// TODO Remove ignore_for_file lines^
///
import 'dart:io';

import 'package:clear_app_helper/core/domain/entities/app_path_provider.dart';
import 'package:clear_app_helper/core/presentation/widgets/loading_indicator.dart';
import 'package:clear_app_helper/core/settings_route_names.dart';
import 'package:clear_app_helper/shared_preferences.dart';
import 'package:clear_app_helper_isar/core/datasources/isar/isar_init.dart';
import 'package:clear_app_helper_isar/core/presentation/isar_db_choice_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../clear_app_helper/example/locator_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  init(); //from locator_service.dart

  Future<void> waitPrefs() async {
    if (!prefsHelper.inited) {
      await Future.delayed(const Duration(milliseconds: 50), () async {
        // log("wait SharedPrefs 50msec");
        await waitPrefs();
      });
    }
  }

  await waitPrefs();
  await initializeDateFormatting('en').then((_) => runApp(const MyApp())); //TODO replace en with your language
}

final isarInit = getIt<IsarInit>();
final prefsHelper = getIt<SharedPreferencesHelper>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class RouteNames extends SettingsRouteNames {
  static String get searchPage => '/searchPage';

  static String get settingsDetailPage => SettingsRouteNames.settingsDetailPage;

  ///
  static String get settingsInfoPage => SettingsRouteNames.settingsInfoPage;
  static String get settingsViewPage => SettingsRouteNames.settingsViewPage;

  ///TODO add your pages
}

class _MyAppState extends State<MyApp> {
  String? isarDBdirectory;
  @override
  Widget build(BuildContext context) {
    Future<Widget> checkDB() async {
      isarDBdirectory = prefsHelper.getString('isarDBdirectory');
      if (isarDBdirectory == null) {
        final Directory dir = await GetIt.I<AppPathProvider>().getApplicationDocumentsDirectory();
        return IsarDbChoicePage(
          isarDBdirectory: '${dir.path}/.isarDB',
          sharedPreferencesHelper: prefsHelper,
          setDirectory: () async => setState(() {
            isarDBdirectory = '_';
          }),
        );
      }

      Future<void> waitIsar() async {
        if (!isarInit.inited) {
          await Future.delayed(const Duration(milliseconds: 50), () async {
            // log("wait Isar 50msec");
            await waitIsar();
          });
        }
      }

      await waitIsar();
      return Container(); //TODO  replace by commented out:
      // return MultiBlocProvider(
      //   providers: getBlocProviders(),
      //   child: DeviceCheck(
      //     ///
      //     ///SEE MyThemeData info for add package:sizer and make all in app more flexible
      //     ///
      //     child: GetMaterialApp(
      //       debugShowCheckedModeBanner: false,
      //       title: '====APP NAME====',
      //       themeMode: GetIt.instance<MyThemeData>().mode,
      //       theme: GetIt.instance<MyThemeData>().light,
      //       darkTheme: GetIt.instance<MyThemeData>().dark,
      //       home: BaseWidget(),
      //       getPages: [
      //         GetPage(name: '/', page: () => const BaseWidget()),
      //         GetPage(
      //           name: RouteNames.settingsInfoPage,
      //           page: () => const SettingsInfoPage(drawer: DrawerWidget()),
      //         ),
      //         GetPage(
      //           name: RouteNames.settingsViewPage,
      //           page: () => const SettingsViewPage(drawer: DrawerWidget()),
      //         ),
      //         GetPage(name: RouteNames.settingsDetailPage, page: () => const SettingsDetailPage()),
      //         GetPage(
      //           name: RouteNames.cardWidgetEditPage,
      //           page: () => const CardWidgetEditPage(drawer: BaseWidget()),
      //         ),
      //       ],
      //       onUnknownRoute: (settings) => MaterialPageRoute(builder: (context) => BaseWidget()),
      //     ),
      //   ),
      // );
    }

    return FutureBuilder(
      future: checkDB(),
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.data == null) return loadingIndicator('isar db check');
        return snapshot.data!;
      },
    );
  }
}
