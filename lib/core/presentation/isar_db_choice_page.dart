import 'dart:io';

import 'package:clear_app_helper/core/domain/entities/app_file_picker.dart';
import 'package:clear_app_helper/core/domain/entities/app_permission.dart';
import 'package:clear_app_helper/core/i18n/core_i18n.dart';
import 'package:clear_app_helper/core/presentation/theme_data.dart';
import 'package:clear_app_helper/core/presentation/widgets/my_scaffold_widget.dart';
import 'package:clear_app_helper/shared_preferences.dart';
import 'package:clear_app_helper_isar/core/i18n/isar_i18n.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

/// This widget is used to choose the Isar DB directory.
/// Used when the Isar DB is not initialized yet.
/// Allows the user to choose a directory for the Isar DB.
/// Also checks for storage permissions.
class IsarDbChoicePage extends StatefulWidget {
  const IsarDbChoicePage({
    required this.isarDBdirectory,
    required this.sharedPreferencesHelper,
    required this.setDirectory,
    super.key,
  });
  final String isarDBdirectory;
  final SharedPreferencesHelper sharedPreferencesHelper;
  final Future<void> Function() setDirectory;

  @override
  State<IsarDbChoicePage> createState() => _IsarDbChoiceWidgetState();
}

class _IsarDbChoiceWidgetState extends State<IsarDbChoicePage> {
  String isarDBdirectory = '';
  SharedPreferencesHelper? prefsHelper;
  late bool storageRequestGranted;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: GetIt.instance<CoreI18n>().defaultAppBarTitle,
      theme: GetIt.instance<MyThemeData>().light,
      darkTheme: GetIt.instance<MyThemeData>().dark,
      home: MyScaffoldWidget(
        body: Column(
          children: [
            Text(GetIt.instance<IsarI18n>().isarDbChoiceTitle),
            Text('${GetIt.instance<IsarI18n>().isarDbChoiceDefaultPathTopic}: $isarDBdirectory'),
            if (!storageRequestGranted) Text(GetIt.instance<IsarI18n>().storageIsDeniedWarning),
            if (Platform.isWindows)
              TextButton(
                onPressed: () async {
                  await GetIt.instance<AppFilePicker>().getDirectoryPath().then((value) async {
                    if (value != null) {
                      if (mounted) {
                        isarDBdirectory = value;
                        storageRequestGranted = false;
                        await _checkStoragePermission();
                        setState(() {});
                      }
                    }
                  });
                },
                child: Text(GetIt.instance<IsarI18n>().isarDbChoicePathButton),
              ),
            if (!Platform.isWindows) Text(GetIt.instance<IsarI18n>().notWindowWarning),
            const SizedBox(height: 10),
            TextButton(
              onPressed: storageRequestGranted
                  ? () async {
                      await prefsHelper?.setString('isarDBdirectory', isarDBdirectory);
                      await widget.setDirectory();
                    }
                  : null,
              child: Text(GetIt.instance<IsarI18n>().isarDbChoicePathConfirmButton),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    prefsHelper = widget.sharedPreferencesHelper;
    isarDBdirectory = widget.isarDBdirectory;
    storageRequestGranted = false;
    _checkStoragePermission();
    super.initState();
  }

  Future<void> _checkStoragePermission() async {
    final permissionStatus = await GetIt.I<AppPermission>().storageRequest();
    final canWriteToDirectory = await GetIt.I<AppPermission>().canWriteToDirectory(isarDBdirectory);
    if (mounted && permissionStatus != null) {
      setState(() {
        storageRequestGranted = !permissionStatus.isDenied && canWriteToDirectory;
      });
    }
  }
}
