import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/db/helper/story_helper.dart';

import 'helper/location_helper.dart';
import 'helper/picture_helper.dart';
import 'local_storage.dart';

///
/// Create by Liqun
/// Date: 2019-09-26
///
class DBManager {
  static final String dbName = "Misstory";
  static final String tableMSLocation = "MSLocation";
  static final String tableLocation = "Location";
  static final String tableStory = "Story";
  static final String tablePerson = "Person";
  static final String tableTag = "Tag";
  static final String tablePicture = "Picture";
  static final String tableCustomParams = "tableCustomParams";
  static final String tableConfirmPoi = "ConfirmPoi";
  static final String tableTimeline = "Timeline";

  static final int dbVersion = 6;

  ///初始化
  static initDB() async {
    /// 原始位置信息表
    Map<String, Field> locationFields = new Map<String, Field>();
    locationFields["id"] = Field(FieldType.Text, primaryKey: true);
    locationFields["time"] = Field(FieldType.Real);
    locationFields["lat"] = Field(FieldType.Real);
    locationFields["lon"] = Field(FieldType.Real);
    locationFields["altitude"] = Field(FieldType.Real);
    locationFields["accuracy"] = Field(FieldType.Real);
    locationFields["vertical_accuracy"] = Field(FieldType.Real);
    locationFields["speed"] = Field(FieldType.Real);
    locationFields["bearing"] = Field(FieldType.Real);
    locationFields["count"] = Field(FieldType.Real);
    locationFields["coord_type"] = Field(FieldType.Text);
    locationFields["timeline_id"] = Field(FieldType.Text);

    /// 位置信息表
    Map<String, Field> mslocationFields = new Map<String, Field>();
    mslocationFields["id"] =
        Field(FieldType.Integer, primaryKey: true, autoIncrement: true);
    mslocationFields["altitude"] = Field(FieldType.Real);
    mslocationFields["speed"] = Field(FieldType.Real);
    mslocationFields["bearing"] = Field(FieldType.Real);
    mslocationFields["citycode"] = Field(FieldType.Text);
    mslocationFields["adcode"] = Field(FieldType.Text);
    mslocationFields["country"] = Field(FieldType.Text);
    mslocationFields["province"] = Field(FieldType.Text);
    mslocationFields["city"] = Field(FieldType.Text);
    mslocationFields["district"] = Field(FieldType.Text);
    mslocationFields["road"] = Field(FieldType.Text);
    mslocationFields["street"] = Field(FieldType.Text);
    mslocationFields["number"] = Field(FieldType.Text);
    mslocationFields["poiname"] = Field(FieldType.Text);
    mslocationFields["errorCode"] = Field(FieldType.Integer);
    mslocationFields["errorInfo"] = Field(FieldType.Text);
    mslocationFields["locationType"] = Field(FieldType.Integer);
    mslocationFields["locationDetail"] = Field(FieldType.Text);
    mslocationFields["aoiname"] = Field(FieldType.Text);
    mslocationFields["address"] = Field(FieldType.Text);
    mslocationFields["poiid"] = Field(FieldType.Text);
    mslocationFields["floor"] = Field(FieldType.Text);
    mslocationFields["description"] = Field(FieldType.Text);
    mslocationFields["time"] = Field(FieldType.Real);
    mslocationFields["updatetime"] = Field(FieldType.Real);
    mslocationFields["provider"] = Field(FieldType.Text);
    mslocationFields["lon"] = Field(FieldType.Real);
    mslocationFields["lat"] = Field(FieldType.Real);
    mslocationFields["accuracy"] = Field(FieldType.Real);
    mslocationFields["isOffset"] = Field(FieldType.Boolean);
    mslocationFields["isFixLastLocation"] = Field(FieldType.Boolean);
    mslocationFields["coordType"] = Field(FieldType.Text);
    mslocationFields["is_delete"] = Field(FieldType.Boolean);
    mslocationFields["pictures"] = Field(FieldType.Text);
    mslocationFields["is_deleted"] = Field(FieldType.Real);
    mslocationFields["isFromPicture"] = Field(FieldType.Real);

    ///故事表
    Map<String, Field> storyFields = new Map<String, Field>();
    storyFields["id"] =
        Field(FieldType.Integer, primaryKey: true, autoIncrement: true);
    storyFields["lon"] = Field(FieldType.Real);
    storyFields["lat"] = Field(FieldType.Real);
    storyFields["altitude"] = Field(FieldType.Real);
    storyFields["city_code"] = Field(FieldType.Text);
    storyFields["ad_code"] = Field(FieldType.Text);
    storyFields["country"] = Field(FieldType.Text);
    storyFields["province"] = Field(FieldType.Text);
    storyFields["city"] = Field(FieldType.Text);
    storyFields["district"] = Field(FieldType.Text);
    storyFields["road"] = Field(FieldType.Text);
    storyFields["street"] = Field(FieldType.Text);
    storyFields["number"] = Field(FieldType.Text);
    storyFields["poi_id"] = Field(FieldType.Text);
    storyFields["poi_name"] = Field(FieldType.Text);
    storyFields["aoi_name"] = Field(FieldType.Text);
    storyFields["address"] = Field(FieldType.Text);
    storyFields["description"] = Field(FieldType.Text);
    storyFields["create_time"] = Field(FieldType.Real);
    storyFields["update_time"] = Field(FieldType.Real);
    storyFields["custom_address"] = Field(FieldType.Text);
    storyFields["default_address"] = Field(FieldType.Text);
    storyFields["desc"] = Field(FieldType.Text);
    storyFields["interval_time"] = Field(FieldType.Real);
    storyFields["is_delete"] = Field(FieldType.Boolean);
    storyFields["is_deleted"] = Field(FieldType.Real);
    storyFields["pictures"] = Field(FieldType.Text);
    storyFields["isFromPicture"] = Field(FieldType.Real);
    storyFields["coord_type"] = Field(FieldType.Text);
    storyFields["uuid"] = Field(FieldType.Text);
    storyFields["write_address"] = Field(FieldType.Text);
    storyFields["radius"] = Field(FieldType.Real);
    storyFields["is_merged"] = Field(FieldType.Real);

    ///tag表
    Map<String, Field> tagFields = new Map<String, Field>();
    tagFields["id"] =
        Field(FieldType.Integer, primaryKey: true, autoIncrement: true);
    tagFields["tag_name"] = Field(FieldType.Text);
    tagFields["story_id"] =
        Field(FieldType.Real, foreignKey: true, to: "${dbName}_$tableStory");

    ///person表
    Map<String, Field> personFields = new Map<String, Field>();
    personFields["id"] =
        Field(FieldType.Integer, primaryKey: true, autoIncrement: true);
    personFields["name"] = Field(FieldType.Text);
    personFields["story_id"] =
        Field(FieldType.Real, foreignKey: true, to: "${dbName}_$tableStory");

    ///picture表
    Map<String, Field> pictureFields = new Map<String, Field>();
    pictureFields["id"] = Field(FieldType.Text, primaryKey: true);
    pictureFields["story_uuid"] = Field(FieldType.Text);
    pictureFields["story_id"] =
        Field(FieldType.Real, foreignKey: true, to: "${dbName}_$tableStory");
    pictureFields["lat"] = Field(FieldType.Real);
    pictureFields["lon"] = Field(FieldType.Real);
    pictureFields["pixelWidth"] = Field(FieldType.Real);
    pictureFields["pixelHeight"] = Field(FieldType.Real);
    pictureFields["creationDate"] = Field(FieldType.Real);
    pictureFields["isSynced"] = Field(FieldType.Real);
    pictureFields["path"] = Field(FieldType.Text);


    ///customParams表
    ///
    Map<String,Field> customParamsField = new Map<String, Field>();

    customParamsField["itemId"] = Field(FieldType.Text, primaryKey: true);
    customParamsField["timeInterval"] = Field(FieldType.Real);
    customParamsField["distanceFilter"] = Field(FieldType.Real);
    customParamsField["storyRadiusMin"] = Field(FieldType.Real);
    customParamsField["storyRadiusMax"] = Field(FieldType.Real);
    customParamsField["storyKeepingTimeMin"] = Field(FieldType.Real);
    customParamsField["poiSearchInterval"] = Field(FieldType.Real);
    customParamsField["refreshHomePageTime"] = Field(FieldType.Real);
    customParamsField["pictureRadius"] = Field(FieldType.Real);
    customParamsField["judgeDistanceNum"] = Field(FieldType.Real);

    ///时间线表
    Map<String, Field> timelineFields = new Map<String, Field>();
    timelineFields["uuid"] = Field(FieldType.Text, primaryKey: true);
    timelineFields["poi_id"] = Field(FieldType.Text);
    timelineFields["poi_name"] = Field(FieldType.Text);
    timelineFields["poi_type"] = Field(FieldType.Text);
    timelineFields["poi_type_code"] = Field(FieldType.Text);
    timelineFields["poi_location"] = Field(FieldType.Text);
    timelineFields["poi_address"] = Field(FieldType.Text);
    timelineFields["distance"] = Field(FieldType.Text);
    timelineFields["country"] = Field(FieldType.Text);
    timelineFields["province"] = Field(FieldType.Text);
    timelineFields["city"] = Field(FieldType.Text);
    timelineFields["district"] = Field(FieldType.Text);
    timelineFields["custom_address"] = Field(FieldType.Text);
    timelineFields["desc"] = Field(FieldType.Text);
    timelineFields["lat"] = Field(FieldType.Real);
    timelineFields["lon"] = Field(FieldType.Real);
    timelineFields["altitude"] = Field(FieldType.Real);
    timelineFields["radius"] = Field(FieldType.Real);
    timelineFields["radius_sd"] = Field(FieldType.Real);
    timelineFields["start_time"] = Field(FieldType.Real);
    timelineFields["end_time"] = Field(FieldType.Real);
    timelineFields["interval_time"] = Field(FieldType.Real);
    timelineFields["is_from_picture"] = Field(FieldType.Real);
    timelineFields["is_delete"] = Field(FieldType.Real);
    timelineFields["need_update_poi"] = Field(FieldType.Real);
    timelineFields["same_id"] = Field(FieldType.Text);


    await FlutterOrmPlugin.createTable(
        dbName, tableMSLocation, mslocationFields);
    await FlutterOrmPlugin.createTable(dbName, tableStory, storyFields);
    await FlutterOrmPlugin.createTable(dbName, tableTag, tagFields);
    await FlutterOrmPlugin.createTable(dbName, tablePerson, personFields);
    await FlutterOrmPlugin.createTable(dbName, tablePicture, pictureFields);
    await FlutterOrmPlugin.createTable(dbName, tableLocation, locationFields);
    await FlutterOrmPlugin.createTable(dbName, tableCustomParams, customParamsField);
    await FlutterOrmPlugin.createTable(dbName, tableTimeline, timelineFields);

    dynamic oldVersion = await LocalStorage.get(LocalStorage.dbVersion);
    if (oldVersion == null) {
      oldVersion = 0;
    }
    if (oldVersion < 1) {
//      print("xxxxxxxxxxxxxxx");
      ///处理更新数据库操作
      //新添加的字段附上默认值
      await PictureHelper().clear();
      await StoryHelper().deletePictureStory();
      await LocationHelper().deletePictureLocation();
      await StoryHelper().updateCoordType();
      await LocalStorage.saveBool(LocalStorage.isStep, false);
      await LocalStorage.saveInt(LocalStorage.dbVersion, dbVersion);
    }

    if (oldVersion < 2) {
      await StoryHelper().updateAllDefaultAddress();
      await LocalStorage.saveInt(LocalStorage.dbVersion, dbVersion);
    }
//    await LocalStorage.saveInt(LocalStorage.dbVersion, 3);
    if (oldVersion < 4) {
      await PictureHelper().clear();
      await StoryHelper().clear();
      await LocationHelper().deletePictureLocation();
      await LocalStorage.saveBool(LocalStorage.isStep, false);
      await LocationHelper().separateOldLocation();
      await LocationHelper().createStoryByOldLocation();
      await StoryHelper().updateUUID();
      await LocalStorage.saveInt(LocalStorage.dbVersion, dbVersion);
    }

    if (oldVersion < 5) {
      await StoryHelper().updateRadius();
      await LocationHelper().updateCount();
      await LocalStorage.saveInt(LocalStorage.dbVersion, dbVersion);
    }

    if (oldVersion < 6) {
      await StoryHelper().updateMerged();
      await LocalStorage.saveInt(LocalStorage.dbVersion, dbVersion);
    }
  }
}
