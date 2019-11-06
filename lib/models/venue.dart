import 'package:json_annotation/json_annotation.dart';
import "flocation.dart";
part 'venue.g.dart';

@JsonSerializable()
class Venue {
  Venue();

  String id;

  String name;

  Flocation location;

  String referralId;

  bool hasPerk;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

  Map<String, dynamic> toJson() => _$VenueToJson(this);
}
