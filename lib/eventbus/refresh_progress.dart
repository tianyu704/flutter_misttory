import 'package:flutter/material.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-26
///
class RefreshProgress {
  RefreshProgress(this.total, this.progress);

  num total;
  num progress;

  bool finish(){
    return total == progress;
  }
}
