import 'package:flutter/material.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-26
///
class RefreshProgress {
  RefreshProgress(this.total, this.count);

  num total;
  num count;

  bool finish() {
    return total == count;
  }

  double progress() {
    return (count ?? 0).toDouble() / total ?? 1;
  }
}
