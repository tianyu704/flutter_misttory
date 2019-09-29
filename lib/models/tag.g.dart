// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) {
  return Tag()
    ..id = json['id'] as num
    ..tagName = json['tag_name'] as String;
}

Map<String, dynamic> _$TagToJson(Tag instance) =>
    <String, dynamic>{'id': instance.id, 'tag_name': instance.tagName};
