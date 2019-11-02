import 'package:json_annotation/json_annotation.dart';
import "venue.dart";
part 'response.g.dart';

@JsonSerializable()
class Response {
  Response();

  List<Venue> venues;

  bool confident;

  factory Response.fromJson(Map<String, dynamic> json) => _$ResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}
