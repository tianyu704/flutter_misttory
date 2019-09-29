// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map<String, dynamic> json) {
  return Person()
    ..id = json['id'] as num
    ..name = json['name'] as String;
}

Map<String, dynamic> _$PersonToJson(Person instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
