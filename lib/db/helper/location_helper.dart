import 'package:flutter/cupertino.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/db/db_manager.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/story.dart';

class LocationHelper {
  static final LocationHelper _instance = new LocationHelper._internal();

  factory LocationHelper() => _instance;

  LocationHelper._internal();

  /// 创建Location一条记录
  Future createLocation(Mslocation location) async {
    if (location != null && location.lat != 0 && location.lon != 0) {
      await FlutterOrmPlugin.saveOrm(
          DBManager.tableLocation, location.toJson());
      return 0;
    }
    return -1;
  }

  /// 读取库中的全部数据
  Future<List> findAllLocations() async {
    List result = await Query(DBManager.tableLocation).all();
    if (result != null && result.length > 0) {
      List<Mslocation> list = [];
      result.reversed.forEach((item) =>
          list.add(Mslocation.fromJson(Map<String, dynamic>.from(item))));
      return list;
    }
    return null;
  }

  ///把库中的数据生成story，根据最后一条story的updateTime以后的数据生成
  Future<void> createStoryByLocation() async {
    num time = 0;
    Story lastStory = await StoryHelper().queryLastStory();
    if (lastStory != null) {
      time = lastStory.updateTime;
    }
    List result = await Query(DBManager.tableLocation)
        .orderBy(["time"]).whereByColumFilters([
      WhereCondiction("time", WhereCondictionType.EQ_OR_MORE_THEN, time)
    ]).all();
    if (result != null && result.length > 0) {
//      debugPrint("=================${result.length}");
      for(num i = 0;i<result.length;i++){
        await StoryHelper().judgeLocation(Mslocation.fromJson(Map<String, dynamic>.from(result[i])));
      }
//      debugPrint("=================createStoryByLocation finish");
    }
  }
}
