import 'package:flutter/material.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-11
///
class Constant {
  static const bool isDebug = !bool.fromEnvironment("dart.vm.product");
  static final String androidMapKey = "77419f4f5b07ffcc0a41cafd2fe763af";
  static final String iosMapKey = "d176134bda27dc962716d3dde1ac7683";

  /// foursquare client_id
  static final String clientId =
      "PVMPPN4X34GCG44Z1SMNPD5YAHFORLSEUSNJSNUN0VNM5DXS";

  /// foursquare client_secret
  static final String clientSecret =
      "N0IHDULNBN0ZFZKUSX1N2YKRSZBZK11UQ2KW4LFJ2S1KBURD";

  /// 高德web api key
  static final String aMapWebKey = "b24df9f1354d51538d60d3e4410af79e";

  /// 高德types为 050000（餐饮服务）、070000（生活服务）、120000（商务住宅）
  static final String aMapTypes = "120000|050000";
}
