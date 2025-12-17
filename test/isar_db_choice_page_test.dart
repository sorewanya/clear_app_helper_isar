import 'package:clear_app_helper/core/domain/entities/app_file_picker.dart';
import 'package:clear_app_helper/core/domain/entities/app_permission.dart';
import 'package:clear_app_helper/core/i18n/core_i18n.dart';
import 'package:clear_app_helper/core/presentation/theme_data.dart';
import 'package:clear_app_helper/shared_preferences.dart';
import 'package:clear_app_helper_isar/core/i18n/isar_i18n.dart';
import 'package:clear_app_helper_isar/core/presentation/isar_db_choice_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';

import 'isar_db_choice_page_test.mocks.dart';

@GenerateMocks([SharedPreferencesHelper, AppPermission, AppFilePicker])
void main() {
  late MockAppFilePicker mockAppFilePicker;
  late MockAppPermission mockAppPermission;
  late MockSharedPreferencesHelper mockPrefsHelper;
  late Future<void> Function() setDirectoryCallback;
  bool callbackCalled = false;
  setDirectoryCallback = () async => callbackCalled = true;

  setUpAll(() {
    mockAppFilePicker = MockAppFilePicker();
    mockAppPermission = MockAppPermission();
    mockPrefsHelper = MockSharedPreferencesHelper();
    GetIt.instance
      ..registerSingleton<CoreI18n>(CoreI18n())
      ..registerSingleton<IsarI18n>(IsarI18n())
      ..registerSingleton<AppFilePicker>(mockAppFilePicker)
      ..registerSingleton<AppPermission>(mockAppPermission)
      ..registerSingleton<MyThemeData>(MyThemeData());
  });

  tearDown(() {
    callbackCalled = false;
  });

  testWidgets('IsarDbChoicePage displays correctly and handles directory selection', (tester) async {
    final initialPath = '/initial/path';
    final selectedPath = '/selected/path';

    when(mockAppFilePicker.getDirectoryPath()).thenAnswer((_) async => selectedPath);
    when(mockAppPermission.request()).thenAnswer((_) async => PermissionStatus.granted);
    when(mockPrefsHelper.setString('isarDBdirectory', selectedPath)).thenAnswer((_) async => true);

    await tester.pumpWidget(
      IsarDbChoicePage(
        isarDBdirectory: initialPath,
        sharedPreferencesHelper: mockPrefsHelper,
        setDirectory: setDirectoryCallback,
      ),
    );

    // Assert initial UI
    expect(find.text(GetIt.instance<IsarI18n>().isarDbChoiceTitle), findsOneWidget);
    expect(find.text('${GetIt.instance<IsarI18n>().isarDbChoiceDefaultPathTopic}: $initialPath'), findsOneWidget);
    expect(find.text(GetIt.instance<IsarI18n>().isarDbChoicePathButton), findsOneWidget);
    expect(find.text(GetIt.instance<IsarI18n>().isarDbChoicePathConfirmButton), findsOneWidget);

    // Simulate directory pick
    await tester.tap(find.text(GetIt.instance<IsarI18n>().isarDbChoicePathButton));
    await tester.pumpAndSettle(); // wait for setState
    await tester.pump(); // wait for setState

    // Verify path updated
    expect(find.text('${GetIt.instance<IsarI18n>().isarDbChoiceDefaultPathTopic}: $selectedPath'), findsOneWidget);

    // Simulate confirm button tap
    await tester.tap(find.text(GetIt.instance<IsarI18n>().isarDbChoicePathConfirmButton));
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(callbackCalled, isTrue);

    // Verify shared preferences saved and callback called
    verify(mockPrefsHelper.setString('isarDBdirectory', selectedPath)).called(1);
  });

  testWidgets('Shows warning when storage permission denied', (tester) async {
    // Arrange
    when(mockAppPermission.request()).thenAnswer((_) async => PermissionStatus.denied);

    // Act
    await tester.pumpWidget(
      IsarDbChoicePage(
        isarDBdirectory: '/path',
        sharedPreferencesHelper: mockPrefsHelper,
        setDirectory: setDirectoryCallback,
      ),
    );

    // Assert
    await tester.pump(); // permission future resolved
    expect(find.text(GetIt.instance<IsarI18n>().storageIsDeniedWarning), findsOneWidget);
  });
}
