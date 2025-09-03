import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:clear_app_helper/settings/domain/entities/settings_description_entity.dart';

part 'isar_settings_description_model.g.dart';

@CopyWith()
@JsonSerializable()
@Collection(inheritance: false)
class IsarSettingsDescription with EquatableMixin implements SettingsDescriptionEntity {
  @override
  final Id id;

  @override
  final String description;

  IsarSettingsDescription({required this.id, required this.description});

  IsarSettingsDescription.fromEntity({required SettingsDescriptionEntity entity})
    : id = entity.id ?? 1,
      description = entity.description;

  static List<IsarSettingsDescription> fromEntityList(List<SettingsDescriptionEntity> modelList) {
    return modelList.map((e) => IsarSettingsDescription.fromEntity(entity: e)).toList();
  }

  //Equatable
  @override
  @ignore
  List<Object?> get props => [description];
  //END Equatable

  ///JSON
  factory IsarSettingsDescription.fromJson(Map<String, dynamic> json) => _$IsarSettingsDescriptionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$IsarSettingsDescriptionToJson(this);
  @override
  @ignore
  get copyWith => _$IsarSettingsDescriptionCWProxyImpl(this);
}
