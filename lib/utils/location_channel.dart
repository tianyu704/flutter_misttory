import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:misstory/models/location.dart';
import 'package:misstory/utils/print_util.dart';

import 'string_util.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-11-20
///
class LocationChannel {
  static final LocationChannel _instance = new LocationChannel._internal();

  factory LocationChannel() => _instance;

  LocationChannel._internal();

  MethodChannel _channel = MethodChannel("com.admqr.misstory")
    ..setMethodCallHandler(_handler);

  final StreamController<Location> _controller =
      StreamController<Location>.broadcast();

  Stream<Location> get onLocationChanged => _controller.stream;

  bool isStart = false;

  /// 开始定位
  Future<void> start(
      {int interval = 3 * 60 * 1000, int distanceFilter = 10}) async {
    isStart = true;
    return await _channel.invokeMethod("start_location",
        {'interval': interval, 'distanceFilter': distanceFilter});
  }

  /// 停止定位
  Future<void> stop() async {
    isStart = false;
    return await _channel.invokeMethod("stop_location");
  }

  ///获取当前定位
  Future<Location> getCurrentLocation() async {
    String result = await _channel.invokeMethod("current_location");
    if (!StringUtil.isEmpty(result)) {
      Map map = json.decode(result);
      return Location.fromJson(Map<String, dynamic>.from(map));
    }
    return null;
  }

  ///获取Android端本地缓存的Location
  Future<String> queryLocationData() async {
    return await _channel.invokeMethod("query_location_data");
  }

  static Future<dynamic> _handler(MethodCall call) async {
    String locationJson = call.arguments;

    switch (call.method) {
      case "locationListener":
//        print("=========$locationJson");
        try {
          if (StringUtil.isNotEmpty(locationJson)) {
            Location location = Location.fromJson(jsonDecode(locationJson));
            LocationChannel()._controller.add(location);
          }
//          print(location.toJson());
        } catch (e) {
          print(e.toString());
        }

        break;
    }
  }

  Future<void> dispose() async {
    await _controller?.close();
  }
}
