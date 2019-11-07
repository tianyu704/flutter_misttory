import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-11-05
///
class ChannelUtil {
  static final ChannelUtil _instance = new ChannelUtil._internal();

  factory ChannelUtil() => _instance;

  ChannelUtil._internal();

  MethodChannel _methodChannel = MethodChannel("com.admqr.misstory");

  Future<String> queryLocation() async {
    return await _methodChannel.invokeMethod("query_location");
  }

  Future<bool> requestLocationPermission() async {
    String result =
        await _methodChannel.invokeMethod("request_location_permission");
    return result == "GRANTED";
  }

  Future<bool> requestStoragePermission() async {
    String result =
        await _methodChannel.invokeMethod("request_storage_permission");
    return result == "GRANTED";
  }
}
