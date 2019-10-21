import 'package:json_annotation/json_annotation.dart';

part 'picture.g.dart';

@JsonSerializable()
class Picture {
  Picture();

  String id;

  num creationDate;

  num pixelWidth;

  num pixelHeight;

  num lat;

  num lon;

  bool isSynced;

  factory Picture.fromJson(Map<String, dynamic> json) => _$PictureFromJson(json);

  Map<String, dynamic> toJson() => _$PictureToJson(this);
}
