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
//  static final String aMapWebKey = "0004af0a0ee3b327d404eff0fb88a1b9";
  static final String aMapWebKey = "b24df9f1354d51538d60d3e4410af79e";

  ///高德poi类型
  /// 010000汽车服务、020000汽车销售、030000汽车维修、050000餐饮服务、060000购物服务、
  /// 070000生活服务、080000体育休闲、090000医疗保健服务、100000住宿服务、110000风景名胜
  /// 120000商务住宅、130000政府机构及社会团体、140000科教文化、150000交通设施、
  /// 160000金融保险、170000公司企业、180000道路附属设施、190000地名地址信息、200000公共设施
  ///220000事件活动、990000同行设施
  static final String aMapTypes = "120000|050000|110000";
}
