import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:misstory/constant.dart';
import 'package:misstory/models/amap_poi.dart';
import 'package:misstory/models/flocation.dart';
import 'package:misstory/models/foursquare.dart';
import 'package:misstory/models/latlonpoint.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/poilocation.dart';
import 'package:misstory/models/venue.dart';
import 'package:misstory/utils/print_util.dart';
import 'package:misstory/utils/string_util.dart';
import '../location_config.dart';
import 'address.dart';
import 'code.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/header_interceptor.dart';
import 'interceptors/log_interceptor.dart';
import 'interceptors/response_interceptor.dart';
import 'interceptors/token_interceptor.dart';
import 'result_data.dart';

///http请求
class HttpManager {
  Dio _dio = new Dio(); // 使用默认配置

  final TokenInterceptors _tokenInterceptors = new TokenInterceptors();

  HttpManager() {
    _dio.interceptors.add(new HeaderInterceptors());

    _dio.interceptors.add(_tokenInterceptors);

    _dio.interceptors.add(new LogsInterceptors());

//    _dio.interceptors.add(new ErrorInterceptors(_dio));

    _dio.interceptors.add(new ResponseInterceptors());

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback = (cert, host, port) {
        return true;
      };
    };
  }

  ///发起网络请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置
  request(url, params, Map<String, dynamic> header, Options option,
      {noTip = false}) async {
    Map<String, dynamic> headers = new HashMap();
    if (header != null) {
      headers.addAll(header);
    }

    if (option != null) {
      option.headers = headers;
    } else {
      option = new Options(method: "get");
      option.headers = headers;
    }

    resultError(DioError e) {
      Response errorResponse;
      if (e.response != null) {
        errorResponse = e.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }
      if (e.type == DioErrorType.CONNECT_TIMEOUT ||
          e.type == DioErrorType.RECEIVE_TIMEOUT) {
        errorResponse.statusCode = Code.NETWORK_TIMEOUT;
      }
      return new ResultData(
        Code.errorHandleFunction(errorResponse.statusCode, e.message, noTip),
        false,
        errorResponse.statusCode,
      );
    }

    Response response;
    try {
      if (option.method.toUpperCase() == "GET") {
        response =
            await _dio.request(url, queryParameters: params, options: option);
      } else {
        response = await _dio.request(url, data: params, options: option);
      }
    } on DioError catch (e) {
      return resultError(e);
    }
    if (response.data is DioError) {
      return resultError(response.data);
    }
    return response.data;
  }

  ///清除授权
  clearAuthorization() {
    _tokenInterceptors.clearAuthorization();
  }

  ///获取授权token
  getAuthorization() async {
    return _tokenInterceptors.getAuthorization();
  }
}

final HttpManager httpManager = new HttpManager();

/// 获取Foursquare poi地点信息
Future<List<AmapPoi>> getFoursquarePoi(
    {String latlon, String near, int radius, int limit = 20}) async {
  if (StringUtil.isNotEmpty(latlon)) {
    try {
      Response response = await Dio().get(
        Address.requestFoursquarePoi(),
        queryParameters: {
          "limit": limit,
          "client_id": Constant.clientId,
          "client_secret": Constant.clientSecret,
          "near": near,
          "radius": radius ?? LocationConfig.poiSearchInterval,
          "ll": latlon,
          "v": DateFormat("yyyyMMdd").format(DateTime.now()),
        },
      );
      if (response.data != null && response.data is Map) {
        Foursquare foursquare = Foursquare.fromJson(
            Map<String, dynamic>.from(response.data as Map));
        if (foursquare != null &&
            foursquare.meta != null &&
            foursquare.meta.code == 200 &&
            foursquare.response != null &&
            foursquare.response.venues != null &&
            foursquare.response.venues.length > 0) {
          List<AmapPoi> amapPois = [];
          AmapPoi amapPoi;
          foursquare.response.venues.forEach((item) {
            amapPoi = AmapPoi()
              ..id = item.id
              ..name = item.name
              ..distance = "${item?.location?.distance}"
              ..address = item.location?.address
              ..location = "${item.location.lng},${item.location?.lat},WGS84"
              ..country = item.location?.country
              ..pname = item.location.state
              ..cityname = item.location?.city
              ..type = (item.categories != null && item.categories.length > 0)
                  ? item.categories[0].name
                  : "";
            amapPois.add(amapPoi);
          });
          return amapPois;
        }
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }
  return null;
}

/// 获取高德poi地点信息
Future<List<AmapPoi>> getAMapPois(
    {num lat = 0, num lon = 0, num radius}) async {
  if (lat != 0 && lon != 0) {
    try {
      Response response = await Dio().get(
        Address.requestAMapPois(),
        queryParameters: {
          "location": "$lon,$lat",
          "extensions": "all",
          "key": Constant.aMapWebKey,
          "radius": radius ?? LocationConfig.poiSearchInterval.toInt(),
        },
      );
      PrintUtil.debugPrint("搜索poi。。。。。。");
      if (response.data != null &&
          response.data is Map &&
          (response.data["status"] == "1" || response.data["status"] == 1)) {
        var regeocode = response.data["regeocode"];
        if (regeocode != null && regeocode is Map) {
          List pois = regeocode["pois"];
          if (pois != null && pois.length > 0) {
            dynamic addressComponent = regeocode["addressComponent"];
            var country;
            var province;
            var city;
            var district;
            if (addressComponent != null && addressComponent is Map) {
              country = addressComponent["country"].toString();
              province = addressComponent["province"].toString();
              city = addressComponent["city"].toString();
              district = addressComponent["district"].toString();
            }
            List<AmapPoi> list = [];
            AmapPoi amapPoi;
            for (Map map in pois) {
              try {
                amapPoi = AmapPoi.fromJson(Map<String, dynamic>.from(map));
                amapPoi.country = country;
                amapPoi.pname = province;
                amapPoi.cityname = city;
                amapPoi.adname = district;
                amapPoi.location = "${amapPoi.location},GCJ02";
                list.add(amapPoi);
              } catch (e) {}
            }
            list.sort((AmapPoi a1, AmapPoi a2) =>
                num.tryParse(a1.distance).compareTo(num.tryParse(a2.distance)));
            return list;
          }
        }
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }
  return null;
}

/// 获取高德poi地点信息
Future<List<AmapPoi>> searchAMapPois(
    {num lat = 0,
    num lon = 0,
    String keywords = "",
    num limit = 20,
    num radius,
    String types,
    num page = 1}) async {
  if (lat != 0 && lon != 0) {
    try {
      Response response = await Dio().get(
        Address.searchAMapPois(),
        queryParameters: {
          "location": "$lon,$lat",
          "keywords": keywords,
          "offset": limit,
          "key": Constant.aMapWebKey,
          "radius": radius ?? LocationConfig.poiSearchInterval.toInt(),
          "types": types ?? LocationConfig.aMapTypes,
          "sortrule": "distance",
          "page": page
        },
      );
      PrintUtil.debugPrint("搜索poi。。。。。。");
      if (response.data != null && response.data is Map) {
        List pois = response.data["pois"];
        if (pois != null && pois.length > 0) {
          List<AmapPoi> list = [];
          AmapPoi amapPoi;
          for (Map map in pois) {
            try {
              amapPoi = AmapPoi.fromJson(Map<String, dynamic>.from(map));
              amapPoi.location = "${amapPoi.location},GCJ02";
              amapPoi.country = "中国";
              list.add(amapPoi);
            } catch (e) {}
          }
          return list;
        }
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }
  return null;
}

//
/////获取腾讯poi集合
//Future<List<AmapPoi>> requestTencentPois(
//    {num lat = 0,
//    num lon = 0,
//    String keywords = "",
//    num limit = 20,
//    num radius,
//    String types,
//    num page = 1}) async {
//  if (lat != 0 && lon != 0) {
//    try {
//      Response response = await Dio().get(
//        Address.requestTencentLocation(),
//        queryParameters: {
//          "get_poi": 1,
//          "key": Constant.tencentKey,
//          "location": "$lat,$lon",
//          "poi_options":
//              "address_format=short;radius=${radius.toInt()};page_size=$limit;page_index=$page",
//        },
//      );
//      PrintUtil.debugPrint("搜索Tencent poi。。。。。。");
//      if (response.data != null && response.data is Map) {
//        Map result = response.data["result"];
//        if (result != null && result.length > 0) {
//          List pois = result["pois"];
//          Map address = result["address_component"];
//          String country = address != null ? address["nation"] : "";
//          if (pois != null && pois.length > 0) {
//            List<AmapPoi> list = [];
//            for (Map map in pois) {
//              AmapPoi amapPoi = AmapPoi();
//              amapPoi.id = map["id"];
//              amapPoi.name = map["title"];
//              amapPoi.address = map["address"];
//              amapPoi.typecode = map["type"].toString();
//              amapPoi.type = map["category"];
//              Map location = map["location"];
//              amapPoi.location = "${location["lng"]},${location["lat"]}";
//              Map adInfo = map["ad_info"];
//              amapPoi.adcode = adInfo["adcode"].toString();
//              amapPoi.cityname = adInfo["city"];
//              amapPoi.pname = adInfo["province"];
//              amapPoi.country = country;
//              amapPoi.distance = map["_distance"].toString();
//              list.add(amapPoi);
//            }
//            return list;
//          }
//        }
//      }
//    } on DioError catch (e) {
//      print(e.response);
//    }
//  }
//  return null;
//}
//
/////获取腾讯poi集合
//Future<List<AmapPoi>> searchTencentPois(
//    {num lat = 0,
//    num lon = 0,
//    String keywords = "",
//    num limit = 20,
//    num radius,
//    String types,
//    num page = 1}) async {
//  if (lat != 0 && lon != 0) {
//    try {
//      Response response = await Dio().get(
//        Address.searchTencentLocation(),
//        queryParameters: {
//          "keyword": keywords,
//          "key": Constant.tencentKey,
//          "boundary": "nearby($lat,$lon,$radius,0)",
//          "orderby": "_distance",
//          "page_size": limit,
//          "page_index": page
//        },
//      );
//      PrintUtil.debugPrint("搜索Tencent poi。。。。。。");
//      if (response.data != null && response.data is Map) {
//        List pois = response.data["data"];
//        if (pois != null && pois.length > 0) {
//          List<AmapPoi> list = [];
//          for (Map map in pois) {
//            AmapPoi amapPoi = AmapPoi();
//            amapPoi.id = map["id"];
//            amapPoi.name = map["title"];
//            amapPoi.address = map["address"];
//            amapPoi.typecode = map["type"].toString();
//            amapPoi.type = map["category"];
//            Map location = map["location"];
//            amapPoi.location = "${location["lng"]},${location["lat"]}";
//            Map adInfo = map["ad_info"];
//            amapPoi.adcode = adInfo["adcode"].toString();
//            amapPoi.cityname = adInfo["city"];
//            amapPoi.distance = map["_distance"].toString();
//            list.add(amapPoi);
//          }
//          return list;
//        }
//      }
//    } on DioError catch (e) {
//      print(e.response);
//    }
//  }
//  return null;
//}
