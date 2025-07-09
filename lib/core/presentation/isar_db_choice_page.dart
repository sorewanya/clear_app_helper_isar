import 'package:clear_app_helper/core/i18n/core_i18n.dart';
import 'package:clear_app_helper_isar/core/i18n/isar_i18n.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:clear_app_helper/core/presentation/theme_data.dart';
import 'package:clear_app_helper/core/presentation/widgets/my_scaffold_widget.dart';
import 'package:clear_app_helper/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

class IsarDbChoicePage extends StatefulWidget {
  const IsarDbChoicePage({
    super.key,
    required this.isarDBdirectory,
    required this.sharedPreferencesHelper,
    required this.setDirectory,
  });
  final String isarDBdirectory;
  final SharedPreferencesHelper sharedPreferencesHelper;
  final Function() setDirectory;

  @override
  State<IsarDbChoicePage> createState() => _IsarDbChoiceWidgetState();
}

class _IsarDbChoiceWidgetState extends State<IsarDbChoicePage> {
  String isarDBdirectory = "";
  SharedPreferencesHelper? prefsHelper;
  @override
  void initState() {
    prefsHelper = widget.sharedPreferencesHelper;
    isarDBdirectory = widget.isarDBdirectory;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: GetIt.instance<CoreI18n>().defaultAppBarTitle,
      themeMode: ThemeMode.system,
      theme: getThemeDataLight(),
      darkTheme: getThemeDataDark(),
      home: MyScaffoldWidget(
        body: Column(
          children: [
            Text(GetIt.instance<IsarI18n>().isarDbChoiceTitle),
            Text("${GetIt.instance<IsarI18n>().isarDbChoiceDefaultPathTopic}: $isarDBdirectory"),
            FutureBuilder(
              future: Permission.storage.request().isDenied,
              builder: (context, asyncSnapshot) {
                return asyncSnapshot.data == false
                    ? SizedBox()
                    : Text(GetIt.instance<IsarI18n>().storageIsDeniedWarning);
              },
            ),
            TextButton(
              onPressed: (() {
                FilePicker.platform.getDirectoryPath().then((value) {
                  if (value != null) {
                    setState(() {
                      isarDBdirectory = value;
                    });
                  }
                });
              }),
              child: Text(GetIt.instance<IsarI18n>().isarDbChoicePathButton),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: (() async {
                await prefsHelper?.prefs.setString('isarDBdirectory', isarDBdirectory);
                widget.setDirectory();
              }),
              child: Text(GetIt.instance<IsarI18n>().isarDbChoicePathConfirmButton),
            ),
          ],
        ),
      ),
    );
  }
}
