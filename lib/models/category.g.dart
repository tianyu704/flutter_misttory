// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category()
    ..id = json['id'] as String
    ..name = json['name'] as String
    ..pluralName = json['pluralName'] as String
    ..shortName = json['shortName'] as String
    ..primary = json['primary'] as bool;
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'pluralName': instance.pluralName,
      'shortName': instance.shortName,
      'primary': instance.primary,
    };
