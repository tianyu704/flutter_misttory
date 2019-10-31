import 'package:json_annotation/json_annotation.dart';
import "location.dart";
part 'venue.g.dart';

@JsonSerializable()
class Venue {
  Venue();

  String id;

  String name;

  Location location;

  String referralId;

  bool hasPerk;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

  Map<String, dynamic> toJson() => _$VenueToJson(this);
}
