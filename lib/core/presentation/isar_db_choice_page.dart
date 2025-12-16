import 'package:clear_app_helper/core/domain/entities/app_file_picker.dart';
import 'package:clear_app_helper/core/i18n/core_i18n.dart';
import 'package:clear_app_helper/core/presentation/theme_data.dart';
import 'package:clear_app_helper/core/presentation/widgets/my_scaffold_widget.dart';
import 'package:clear_app_helper/shared_preferences.dart';
import 'package:clear_app_helper_isar/core/i18n/isar_i18n.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

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

  ///FIXME добавь проверку папки на возможность записи!

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
            FutureBuilder(
              future: Permission.storage.request().isDenied,
              builder: (context, asyncSnapshot) {
                return asyncSnapshot.data == false
                    ? SizedBox()
                    : Text(GetIt.instance<IsarI18n>().storageIsDeniedWarning);
              },
            ),
            TextButton(
              onPressed: () {
                GetIt.instance<AppFilePicker>().getDirectoryPath().then((value) {
                  if (value != null) {
                    if (mounted) {
                      setState(() {
                        isarDBdirectory = value;
                      });
                    }
                  }
                });
              },
              child: Text(GetIt.instance<IsarI18n>().isarDbChoicePathButton),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                await prefsHelper?.setString('isarDBdirectory', isarDBdirectory);
                await widget.setDirectory();
              },
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
    super.initState();
  }
}
