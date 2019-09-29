import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/utils/string_util.dart';
import '../db_manager.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:amap_base/amap_base.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-09-29
///
class StoryHelper {
  final String tableName = "Story";
  final String columnId = "id";
  final String columnTime = "time";
  final num judgeDistanceNum = 5000;
  static final StoryHelper _instance = new StoryHelper._internal();

  factory StoryHelper() => _instance;

  StoryHelper._internal();

  /// 创建story
  Future createStory(Story story) async {
    if (story != null) {
      await FlutterOrmPlugin.saveOrm(DBManager.tableStory, story.toJson());
    }
  }

  /// 更新story时间
  Future updateStoryTime(num storyId, num time) async {
    await Query(DBManager.tableStory)
        .primaryKey([storyId]).update({"update_time": time});
  }

  Future<Story> queryLastStory() async {
    Map result = await Query(DBManager.tableStory).orderBy([
      "id desc",
    ]).first();
    if (result != null) {
      return Story.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }

  Story createStoryWithLocation(Mslocation location) {
    Story story = Story();
    story.lat = location.lat;
    story.lon = location.lon;
    story.poiId = location.poiid;
    story.aoiName = location.aoiname;
    story.poiName = location.poiname;
    story.country = location.country;
    story.province = location.province;
    story.city = location.city;
    story.cityCode = location.citycode;
    story.adCode = location.adcode;
    story.address = location.address;
    story.road = location.road;
    story.street = location.street;
    story.number = location.number;
    story.description = location.description;

    story.createTime = location.time;
    story.updateTime = location.time;
    //TODO:
    return story;
  }

  Future updateStory(Story story) async {
    //TODO:
  }

  ///坐标点更新故事或创建故事
  Future<void> judgeLocation(Mslocation location) async {
    if (location != null &&
        location.lon != 0 &&
        location.lat != 0 &&
        (StringUtil.isNotEmpty(location.aoiname) ||
            StringUtil.isNotEmpty(location.poiname)) &&
        StringUtil.isNotEmpty(location.address)) {
      Story story = await queryLastStory();
      bool isNew = false;
      if (story == null) {
        isNew = true;
      } else if (StringUtil.isEmpty(location.aoiname)) {
        if (location.poiname == story.poiName) {
        } else {
          isNew = true;
        }
      } else if (location.aoiname == story.aoiName) {
      } else {
        isNew = true;
      }
      //
      if (isNew) {
        await createStory(createStoryWithLocation(location));
      } else {
        if (await getDistanceBetween(location, story) > judgeDistanceNum) {
          await createStory(createStoryWithLocation(location));
        } else {
          await updateStoryTime(story.id, location.time);
        }
      }
    }
  }

  ///求值：两个坐标点的距离
  Future<double> getDistanceBetween(Mslocation location, Story story) async {
    LatLng latLng1 = LatLng(location.lat, location.lon);
    LatLng latLng2 = LatLng(story.lat, story.lon);
    return await CalculateTools().calcDistance(latLng1, latLng2);
  }
}
