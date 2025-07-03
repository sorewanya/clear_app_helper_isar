import 'package:clear_app_helper/core/hash_func.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:clear_app_helper_isar/core/datasources/isar/isar_log.dart';
import 'package:clear_app_helper/settings/domain/entities/enums_of_settings.dart';
import 'package:clear_app_helper/settings/domain/entities/settings_entity.dart';
import 'package:clear_app_helper/settings/domain/entities/settings_log_action.dart';
import 'package:clear_app_helper/settings/domain/entities/settings_types.dart';

part 'isar_settings_model.g.dart';

@CopyWith()
@JsonSerializable()
@Collection(inheritance: false)
class IsarSettings with EquatableMixin implements SettingsEntity {
  @override
  Id get id => fastHash(name);

  @override
  String name;
  @override
  final String defaultValue;
  @override
  final String? userValue;
  @override
  final int type; // use SettingsTypeEnum
  @override
  final int? confirmType;
  @override
  final List<String>? values;
  @override
  final bool isDeleted;

  IsarSettings({
    required this.name,
    required this.defaultValue,
    this.userValue,
    required this.type,
    this.confirmType,
    this.values,
    this.isDeleted = false,
  });

  IsarSettings.fromEnum({required EnumsOfSettings e, required this.defaultValue, this.values, this.confirmType})
    : name = e.name,
      userValue = null,
      type = e.typeIndex,
      isDeleted = false;

  IsarSettings.fromEntity({required SettingsEntity entity})
    : name = entity.name,
      defaultValue = entity.defaultValue,
      userValue = entity.userValue,
      type = entity.type,
      confirmType = entity.confirmType,
      values = entity.values,
      isDeleted = entity.isDeleted;

  static List<IsarSettings> fromEntityList(List<SettingsEntity> modelList) {
    return modelList.map((e) => IsarSettings.fromEntity(entity: e)).toList();
  }

  //Equatable
  @override
  @ignore
  List<Object?> get props => [name, defaultValue, userValue, type, confirmType, values, isDeleted];
  //END Equatable

  @override
  String get getUserOrDefaultValueAsString => userValue ?? defaultValue;
  @override
  SettingsEntity getSettingsWithNextVariant() => this;

  @override
  SettingsEntity toType() {
    return switch (SettingsTypeEnum.values[type]) {
      SettingsTypeEnum.integer => SettingsInt.fromEntity(this) ?? this,
      SettingsTypeEnum.boolean => SettingsBool.fromEntity(this) ?? this,
      SettingsTypeEnum.icon => SettingsIcon.fromEntity(this) ?? this,
      SettingsTypeEnum.string => this,
      SettingsTypeEnum.dirPath => this,
      SettingsTypeEnum.filePath => SettingsFilePath.fromEntity(this) ?? this,
      SettingsTypeEnum.value => SettingsValue.fromEntity(this) ?? this,
      SettingsTypeEnum.listOfInt => SettingsListOfInt.fromEntity(this) ?? this,
      SettingsTypeEnum.listOfValues => SettingsListOfValues.fromEntity(this) ?? this,
      SettingsTypeEnum.listOfString => SettingsListOfString.fromEntity(this) ?? this,
      SettingsTypeEnum.listOfValuesBase => this,
      SettingsTypeEnum.listOfValuesExtend => SettingsListOfValuesExtend.fromEntity(this) ?? this,
      SettingsTypeEnum.savedSearch => SettingsSavedSearch.fromEntity(this) ?? this,
      SettingsTypeEnum.rfwWidget => this,
      SettingsTypeEnum.doublee => SettingsInt.fromEntity(this) ?? this,
    };
  }

  ///JSON
  factory IsarSettings.fromJson(Map<String, dynamic> json) => _$IsarSettingsFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$IsarSettingsToJson(this);
  @override
  get copyWith => _$IsarSettingsCWProxyImpl(this);
}

@Collection(inheritance: false)
@JsonSerializable()
class IsarSettingsLog with EquatableMixin implements IsarLog {
  @override
  Id? id;
  @override
  final DateTime timestamp;
  @override
  final int itemId;
  final String? settedValue;
  @enumerated
  final SettingsLogAction logAction;
  //Equatable
  @override
  @ignore
  List<Object?> get props => [id, timestamp, itemId, settedValue, logAction];
  //END Equatable

  IsarSettingsLog({required this.itemId, required this.logAction, this.settedValue})
    : id = Isar.autoIncrement,
      timestamp = DateTime.now();

  ///JSON
  factory IsarSettingsLog.fromJson(Map<String, dynamic> json) => _$IsarSettingsLogFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$IsarSettingsLogToJson(this);
  @override
  get copyWith => throw UnsupportedError('copyWith not implemented $runtimeType');
}
