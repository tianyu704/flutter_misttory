import '../constant.dart';

const int pageSize = 30;

///地址数据
class Address {
  static const String develop = "https://sleep-dev.jappstore.com/";
  static const String release = "https://sleep.jappstore.com/";
  static const String host = Constant.isDebug ? develop : release;

  ///获取foursquare poi信息
  static requestFoursquarePoi() {
    return "https://api.foursquare.com/v2/venues/search";
  }

  ///获取高德poi信息
  static requestAMapPois() {
    return "https://restapi.amap.com/v3/geocode/regeo";
  }

  ///获取高德poi信息
  static searchAMapPois() {
    return "https://restapi.amap.com/v3/place/around";
  }

  ///获取腾讯坐标信息
  static searchTencentLocation() {
    return "https://apis.map.qq.com/ws/place/v1/search";
  }

  ///搜索腾讯坐标信息
  static requestTencentLocation() {
    return "https://apis.map.qq.com/ws/geocoder/v1/";
  }

}
