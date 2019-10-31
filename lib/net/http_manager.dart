import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:misstory/constant.dart';
import 'package:misstory/models/foursquare.dart';
import 'package:misstory/models/location.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/venue.dart';
import 'package:misstory/utils/string_util.dart';
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

    _dio.interceptors.add(new ErrorInterceptors(_dio));

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

/// 获取用户信息
Future<Mslocation> requestLocation(Mslocation mslocation) async {
  if (mslocation != null && mslocation.errorCode == 0) {
    try {
      Response response = await Dio().get(
        Address.requestLocation(),
        queryParameters: {
          "limit": 1,
          "client_id": Constant.clientId,
          "client_secret": Constant.clientSecret,
          "ll": "${mslocation.lat},${mslocation.lon}",
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
          Venue venue = foursquare.response.venues[0];
          mslocation.aoiname = venue.name;
          mslocation.poiname = venue.name;
          if (venue.location != null) {
            Location location = venue.location;
            if (!StringUtil.isEmpty(location.country)) {
              mslocation.country = location.country;
            }
            if (!StringUtil.isEmpty(location.city)) {
              mslocation.city = location.city;
            }
            if (!StringUtil.isEmpty(location.state)) {
              mslocation.province = location.state;
            }
            if (!StringUtil.isEmpty(location.address)) {
              mslocation.address = location.address;
            }
          }
          return mslocation;
        }
      }
    } on DioError catch (e) {
      print(e.response);
    }
  }
  return null;
}