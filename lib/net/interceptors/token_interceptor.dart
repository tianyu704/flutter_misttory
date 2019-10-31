import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:misstory/db/local_storage.dart';

import '../../constant.dart';

///Token拦截器
class TokenInterceptors extends InterceptorsWrapper {
  String _token;

  @override
  onRequest(RequestOptions options) async {
    //授权码
    if (_token == null) {
      var authorizationCode = await getAuthorization();
      if (authorizationCode != null) {
        _token = authorizationCode;
      }
    }
    options.headers["authtoken"] = _token;
//    options.headers["source"] = Constant.APP_KEY;
    return options;
  }

  @override
  onResponse(Response response) async {
    try {
      debugPrint("--------${response.statusCode.toString()}");
      if (response.statusCode == 200 &&
          response.headers.value("authtoken") != null) {
        _token = response.headers.value("authtoken");
        debugPrint(_token);
        await LocalStorage.save(LocalStorage.token, _token);
      }
    } catch (e) {
      print(e);
    }
    return response;
  }

  ///清除授权
  clearAuthorization() {
    this._token = null;
    LocalStorage.remove(LocalStorage.token);
  }

  ///获取授权token
  getAuthorization() async {
    String token = await LocalStorage.get(LocalStorage.token);
    if (token == null) {
      //TODO
      //去登录
    } else {
      this._token = token;
      return token;
    }
  }
}
