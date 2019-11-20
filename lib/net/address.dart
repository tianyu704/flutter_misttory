import '../constant.dart';

const int pageSize = 30;

///地址数据
class Address {
  static const String develop = "https://sleep-dev.jappstore.com/";
  static const String release = "https://sleep.jappstore.com/";
  static const String host = Constant.isDebug ? develop : release;

  ///获取foursquare位置信息
  static requestLocation() {
    return "https://api.foursquare.com/v2/venues/search";
  }

  ///获取高德位置poi信息
  static requestAMapPois() {
    return "https://restapi.amap.com/v3/place/around";
  }

  ///获取高德坐标信息
  static requestAMapLocation() {
    return "https://restapi.amap.com/v3/place/around";
  }

}
