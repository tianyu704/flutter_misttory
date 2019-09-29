import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';

///
/// Create by Liqun
/// Date: 2019-09-26
///
class DBManager {
  static final String dbName = "Misstory";
  static final String tableLocation = "MSLocation";
  static final String tableStory = "Story";
  static final String tablePerson = "Person";
  static final String tableTag = "Tag";

  ///初始化
  static initDB() async {
    /// 位置信息表
    Map<String, Field> locationFields = new Map<String, Field>();
    locationFields["id"] =
        Field(FieldType.Integer, primaryKey: true, autoIncrement: true);
    locationFields["altitude"] = Field(FieldType.Real);
    locationFields["speed"] = Field(FieldType.Real);
    locationFields["bearing"] = Field(FieldType.Real);
    locationFields["citycode"] = Field(FieldType.Text);
    locationFields["adcode"] = Field(FieldType.Text);
    locationFields["country"] = Field(FieldType.Text);
    locationFields["province"] = Field(FieldType.Text);
    locationFields["city"] = Field(FieldType.Text);
    locationFields["district"] = Field(FieldType.Text);
    locationFields["road"] = Field(FieldType.Text);
    locationFields["street"] = Field(FieldType.Text);
    locationFields["number"] = Field(FieldType.Text);
    locationFields["poiname"] = Field(FieldType.Text);
    locationFields["errorCode"] = Field(FieldType.Integer);
    locationFields["errorInfo"] = Field(FieldType.Text);
    locationFields["locationType"] = Field(FieldType.Integer);
    locationFields["locationDetail"] = Field(FieldType.Text);
    locationFields["aoiname"] = Field(FieldType.Text);
    locationFields["address"] = Field(FieldType.Text);
    locationFields["poiid"] = Field(FieldType.Text);
    locationFields["floor"] = Field(FieldType.Text);
    locationFields["description"] = Field(FieldType.Text);
    locationFields["time"] = Field(FieldType.Real);
    locationFields["provider"] = Field(FieldType.Text);
    locationFields["lon"] = Field(FieldType.Real);
    locationFields["lat"] = Field(FieldType.Real);
    locationFields["accuracy"] = Field(FieldType.Real);
    locationFields["isOffset"] = Field(FieldType.Integer);
    locationFields["isFixLastLocation"] = Field(FieldType.Integer);
    locationFields["coordType"] = Field(FieldType.Text);

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
    storyFields["create_time"] = Field(FieldType.Text);
    storyFields["update_time"] = Field(FieldType.Text);
    storyFields["custom_address"] = Field(FieldType.Text);

    ///tag表
    Map<String, Field> tagFields = new Map<String, Field>();
    tagFields["id"] =
        Field(FieldType.Integer, primaryKey: true, autoIncrement: true);
    tagFields["tag_name"] = Field(FieldType.Text);
    tagFields["story_id"] =
        Field(FieldType.Text, foreignKey: true, to: "${dbName}_$tableStory");

    ///person表
    Map<String, Field> personFields = new Map<String, Field>();
    personFields["id"] =
        Field(FieldType.Integer, primaryKey: true, autoIncrement: true);
    personFields["name"] = Field(FieldType.Text);
    personFields["story_id"] =
        Field(FieldType.Text, foreignKey: true, to: "${dbName}_$tableStory");

    FlutterOrmPlugin.createTable(dbName, tableLocation, locationFields);
    FlutterOrmPlugin.createTable(dbName, tableStory, storyFields);
    FlutterOrmPlugin.createTable(dbName, tableTag, tagFields);
    FlutterOrmPlugin.createTable(dbName, tablePerson, personFields);
  }
}
