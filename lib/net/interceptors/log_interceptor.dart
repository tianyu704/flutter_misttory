import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../constant.dart';

///
///Log 拦截器
///
class LogsInterceptors extends InterceptorsWrapper {
  @override
  onRequest(RequestOptions options) async{
    if (Constant.isDebug) {
      debugPrint("请求url：${options.path}");
      debugPrint('请求头: ' + options.headers.toString());
      if (options.method.toUpperCase() == "GET" &&
          options.queryParameters != null) {
        debugPrint('请求参数: ' + options.queryParameters.toString());
      } else {
        debugPrint('请求参数: ' + options.data.toString());
      }
    }
    return options;
  }

  @override
  onResponse(Response response) async{
    if (Constant.isDebug) {
      if (response != null) {
        debugPrint('返回参数: ' + response.toString());
      }
    }
    return response; // continue
  }

  @override
  onError(DioError err) async{
    if (Constant.isDebug) {
      debugPrint('请求异常: ' + err.toString());
      debugPrint('请求异常信息: ' + err.response?.toString() ?? "");
    }
    return err;
  }
}
