import 'package:clear_app_helper/settings/domain/entities/settings_description_entity.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:isar_community/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'isar_settings_description_model.g.dart';

@CopyWith()
@JsonSerializable()
@Collection(inheritance: false)
// ignore: avoid_implementing_value_types
class IsarSettingsDescription with EquatableMixin implements SettingsDescriptionEntity {
  IsarSettingsDescription({required this.id, required this.description});

  IsarSettingsDescription.fromEntity({required SettingsDescriptionEntity entity})
    : id = entity.id ?? 1,
      description = entity.description;

  ///JSON
  factory IsarSettingsDescription.fromJson(Map<String, dynamic> json) => _$IsarSettingsDescriptionFromJson(json);

  @override
  final Id id;

  @override
  final String description;

  @override
  @ignore
  dynamic get copyWith => _$IsarSettingsDescriptionCWProxyImpl(this);
  //END Equatable

  //Equatable
  @override
  @ignore
  List<Object?> get props => [description];
  @override
  Map<String, dynamic> toJson() => _$IsarSettingsDescriptionToJson(this);
  static List<IsarSettingsDescription> fromEntityList(List<SettingsDescriptionEntity> modelList) {
    return modelList.map((e) => IsarSettingsDescription.fromEntity(entity: e)).toList();
  }
}
