import 'package:flutter/material.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-09-29
///
class StringUtil {
  static bool isEmpty(String s) {
    return s == null || s.isEmpty;
  }

  static bool isNotEmpty(String s) {
    return !isEmpty(s);
  }
}
