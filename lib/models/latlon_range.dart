import 'package:flutter/material.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-11-20
///
class LatlonRange {
  num minLat;
  num maxLat;
  num minLon;
  num maxLon;

  @override
  String toString() {
    // TODO: implement toString
    return '{"minLat":$minLat,"maxLat":$maxLat,"minLon":$minLon,"maxLon":$maxLon}';
  }
}
