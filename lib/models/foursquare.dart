import 'package:json_annotation/json_annotation.dart';
import "meta.dart";
import "response.dart";
part 'foursquare.g.dart';

@JsonSerializable()
class Foursquare {
  Foursquare();

  Meta meta;

  Response response;

  factory Foursquare.fromJson(Map<String, dynamic> json) => _$FoursquareFromJson(json);

  Map<String, dynamic> toJson() => _$FoursquareToJson(this);
}
