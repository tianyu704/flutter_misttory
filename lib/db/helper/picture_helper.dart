import 'package:flutter/material.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:local_image_provider/local_image_provider.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/picture.dart';

import '../db_manager.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-18
///
class PictureHelper {
  static final PictureHelper _instance = PictureHelper._internal();

  factory PictureHelper() => _instance;

  PictureHelper._internal();

  fetchAppSystemPicture() async {
    Picture p = await PictureHelper().queryOldestPicture();
    num time = 0;
    if (p != null) {
      time = p.creationDate;
    }
    await LocalImageProvider().initialize();
    num start = DateTime.now().millisecondsSinceEpoch;
    List<LocalImage> list = [];
    if (time == 0) {
      list = await LocalImageProvider().findLatest(0);
    } else {
      list = await LocalImageProvider().findBeforeTime(time: time);
    }
    debugPrint(
        "======查询到${list?.length}张照片，用时${DateTime.now().millisecondsSinceEpoch - start}毫秒");
    if (list != null && list.length > 0) {
      for (LocalImage image in list) {
        if (!(await PictureHelper().isExistPictureWithId(image.id))) {
          await createPicture(createPictureModelWithLocalImage(image));
        }
      }
    }
    debugPrint(
        " 存储完Picture表，用时${DateTime.now().millisecondsSinceEpoch - start}毫秒");
  }

  Picture createPictureModelWithLocalImage(LocalImage image) {
    Picture p = Picture();

    p.lat = image.lat;
    p.lon = image.lon;
    p.id = image.id;
    p.creationDate = image.creationDate;
    p.pixelHeight = image.pixelHeight;
    p.pixelWidth = image.pixelWidth;
    p.path = image.path;
    p.isSynced = 0;
    //debugPrint("json ：${p.toJson()}");
    return p;
  }

  /// 创建Picture 并存库
  Future<bool> createPicture(Picture p) async {
    ///这里无条件存储Picture不做处理
    if (p != null) {
      await FlutterOrmPlugin.saveOrm(DBManager.tablePicture, p.toJson());
      return true;
    }
    return false;
  }

  /// 更新图片同步成location状态
  Future<bool> updatePictureStatus(Picture p) async {
    if (p != null) {
      await Query(DBManager.tablePicture)
          .primaryKey([p.id]).update({"isSynced": 1});
      return true;
    }
    return false;
  }

  ///按主键查询数据库中是否存在该条数据
  Future<bool> isExistPictureWithId(String id) async {
    Map result = await Query(DBManager.tablePicture).whereBySql("id = ?", [id]).first();
    if (result != null) {
      return true;
    }
    return false;
  }
  /// 查询存储在picture表中最早一条数据
  Future<Picture> queryOldestPicture() async {
    Map result = await Query(DBManager.tablePicture).orderBy([
      "creationDate",
    ]).first();
    if (result != null && result.length > 0) {
      return Picture.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }
  ///📌查询并转化picture为location
  convertPicturesToLocations () async {
    debugPrint("开始执行p 转 l");

    List<Picture> list = await queryPictureConverted();
    if (list == null || list.length == 0) {
      Mslocation l = await LocationHelper().queryOldestLocation();
      num time = (l == null) ? 0 : l.time;
      await convertPicturesAfterTime(1569541141000);
      //await convertPicturesBeforeTime(time);
    } else {
      Picture earliestP = list.last;
      Picture newestP = list.first;
      await convertPicturesAfterTime(newestP.creationDate);
      //await convertPicturesBeforeTime(earliestP.creationDate);
    }
    debugPrint("结束执行p 转 l");
  }
  ///使用app后
  convertPicturesAfterTime(num time) async {
    List afterList = await findPicturesAfterTime(time);
    if (afterList != null && afterList.length > 0) {
      for (Picture p in afterList)
         await LocationHelper().createLocationWithPicture(p,false);
      }
      debugPrint("使用app后数据同步完成location");
    }
  }
  ///使用app前
  convertPicturesBeforeTime(num time) async {
    List beforeList = await findPicturesBeforeTime(time);
    if (beforeList != null && beforeList.length > 0) {
      for (Picture p in beforeList) {
        await LocationHelper().createLocationWithPicture(p,true);
      }
      debugPrint("使用app前数据同步完成location");
    }
  }
  ///📌查询未转化为location的图片集合
  ///从指定时间到当前的未同步的全部图片集合
  Future<List> findPicturesAfterTime(num time) async {
    List result;
    if (time == 0) {
      result = await Query(DBManager.tablePicture)
          .orderBy(["creationDate desc"]).whereByColumFilters([
        WhereCondiction("isSynced", WhereCondictionType.IN, [0]),
      ]).all();
    }  else {
      result = await Query(DBManager.tablePicture)
          .orderBy(["creationDate desc"]).whereByColumFilters([
        WhereCondiction("creationDate", WhereCondictionType.MORE_THEN, time),
        WhereCondiction("isSynced", WhereCondictionType.IN, [0]),
      ]).all();
    }
    List<Picture> list = [];
    if (result != null && result.length > 0) {
      result.forEach((item) {
        Picture p = Picture.fromJson(Map<String, dynamic>.from(item));
        list.add(p);
      });
      return list;
    }
    return null;
  }
  ///从最早的到到指定时间的未同步的全部图片集合
  Future<List> findPicturesBeforeTime(num time) async {

    if (time == 0) {
      time = DateTime.now().millisecondsSinceEpoch;
    }
    List result = await Query(DBManager.tablePicture)
        .orderBy(["creationDate desc"]).whereByColumFilters([
      WhereCondiction("creationDate", WhereCondictionType.LESS_THEN, time),
      WhereCondiction("isSynced", WhereCondictionType.IN, [0]),
    ]).all();

    List<Picture> list = [];
    if (result != null && result.length > 0) {
      result.forEach((item) {
        Picture p = Picture.fromJson(Map<String, dynamic>.from(item));
        list.add(p);
      });
      return list;
    }
    return null;
  }

  ///查询已转化图片的集合：目的是拿到最大最小时间
  Future<List> queryPictureConverted() async {
     List result =  await Query(DBManager.tablePicture)
         .orderBy(["creationDate desc"])
         .whereByColumFilters([WhereCondiction("isSynced", WhereCondictionType.IN, [1]),
     ]).all();
     List<Picture> list = [];
     if (result != null && result.length > 0) {
       result.forEach((item) {
         Picture p = Picture.fromJson(Map<String, dynamic>.from(item));
         list.add(p);
       });
       return list;
     }
     return null;
  }









