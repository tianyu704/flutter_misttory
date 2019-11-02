import '../constant.dart';

const int pageSize = 30;

///地址数据
class Address {
  static const String develop = "https://sleep-dev.jappstore.com/";
  static const String release = "https://sleep.jappstore.com/";
  static const String host = Constant.isDebug ? develop : release;

  ///获取用户信息
  static requestLocation() {
    return "https://api.foursquare.com/v2/venues/search";
  }

}
