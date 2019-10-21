import 'package:flutter/material.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:local_image_provider/local_image_provider.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/models/picture.dart';
import 'package:amap_base/amap_base.dart';

import '../db_manager.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-18
///
class PictureHelper {
  static final PictureHelper _instance = PictureHelper._internal();

  factory PictureHelper() => _instance;

  PictureHelper._internal();








  Future<Picture> createPictureWithLocalImage(LocalImage image) async {
    Picture p = Picture();

    p.lat = image.lat;
    p.lon = image.lon;
    p.id = image.id;
    p.creationDate = image.creationDate;
    p.pixelHeight = image.pixelHeight;
    p.pixelWidth = p.pixelWidth;
    p.isSynced = false;
    debugPrint("json ：${p.toJson()}");
    return p;
  }

  /// 创建Picture 并存库
  Future<bool> createPicture(Picture p) async {
    //TODO:这里过滤了经纬度为0的点
    if (p != null && p.lat != 0 && p.lon != 0) {
      await FlutterOrmPlugin.saveOrm(DBManager.tablePicture, p.toJson());
      debugPrint("xsave ${p.id}");
      return true;
    }
    return false;
  }

  /// 更新图片同步成location状态
  Future<bool> updatePictureStatus(Picture p) async {
    if (p != null) {
      await Query(DBManager.tablePicture)
          .primaryKey([p.id]).update({"isSynced": true});
      return true;
    }
    return false;
  }

  /// 查询存储在picture表中最后一条数据
  Future<Picture> queryLastLocation() async {
    Map result = await Query(DBManager.tablePicture).orderBy([
      "creationDate desc",
    ]).first();
    if (result != null && result.length > 0) {
      return Picture.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }


}
