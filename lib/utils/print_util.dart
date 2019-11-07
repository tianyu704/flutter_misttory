import 'package:flutter/material.dart';
import 'package:misstory/constant.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-11-05
///
class PrintUtil {
  static debugPrint(Object object) {
    if (Constant.isDebug) {
      print(object);
    }
  }
}
