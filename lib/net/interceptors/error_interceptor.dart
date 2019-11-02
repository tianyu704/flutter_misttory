import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

import '../code.dart';
import '../result_data.dart';

///
/// 错误拦截
///
class ErrorInterceptors extends InterceptorsWrapper {
  final Dio _dio;

  ErrorInterceptors(this._dio);

  @override
  onRequest(RequestOptions options) async {
    //没有网络
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return _dio.resolve(new ResultData(
          Code.errorHandleFunction(
              Code.NETWORK_ERROR, "请检查您的网络或网络权限是否开启", false),
          false,
          Code.NETWORK_ERROR));
    }
    return options;
  }
}
