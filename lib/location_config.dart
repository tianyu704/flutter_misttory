import 'models/customparams.dart';
import 'package:misstory/db/helper/customparams_helper.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-10
///
class LocationConfig {
  /// 判断2个点距离是否超出judgeDistanceNum
  static num judgeDistanceNum = 3000;

  /// 每隔interval毫秒定位一次
  static num interval = 60 * 1000 ;

  /// 每隔distanceFilter米定位一次
  static num distanceFilter = 10.0;

  /// 停留时长>judgeUsefulLocation毫秒的点算作一个story
  static num judgeUsefulLocation = 5 * 60 * 1000;

  /// 首页每隔多久刷新一次最新页面显示数据
  static num refreshTime = 60;

  /// poi搜索范围半径
  static num poiSearchInterval = 1000;

  /// 图片经纬度半径,判断是否在同一位置
  static num pictureRadius = 100;

  /// 地点经纬度半径,判断是否在同一位置
  static num locationRadius = 100;

  /// 地点经纬度最大半径
  static num locationMaxRadius = 200;

  /// 2个相邻且相同的地点之间的时间间隔，超过该时间算作一个点，没超过就合并
  static num intervalGap = 60 * 1000 * 30;

  static num storyRadiusMin = 10;
  static num storyRadiusMax = 200;

  static resetData() async {
    LocationConfig.interval = 60 * 1000 * 3;
    LocationConfig.distanceFilter = 1000;
    LocationConfig.storyRadiusMax = 200;
    LocationConfig.storyRadiusMin = 10;
    LocationConfig.judgeUsefulLocation = 3 * 60 * 1000;
    LocationConfig.poiSearchInterval = 1000;
    LocationConfig.pictureRadius = 100;
    LocationConfig.refreshTime = 60;
    LocationConfig.judgeDistanceNum = 3000;
    await CustomParamsHelper().delete();
    await updateDynamicData();
  }

  ///更新静态数据源
  static updateDynamicData() async {
    Customparams params = await CustomParamsHelper().find();
    // print(params.timeInterval);
    if (params == null) {
      params = Customparams();
      print("CC");
      params.itemId = "1";
      params.timeInterval = LocationConfig.interval;
      params.distanceFilter = LocationConfig.distanceFilter;
      params.storyRadiusMax = LocationConfig.storyRadiusMax;
      params.storyRadiusMin = LocationConfig.storyRadiusMin;
      params.storyKeepingTimeMin = LocationConfig.judgeUsefulLocation;
      params.poiSearchInterval = LocationConfig.poiSearchInterval;
      params.pictureRadius = LocationConfig.pictureRadius;
      params.refreshHomePageTime = LocationConfig.refreshTime;
      params.judgeDistanceNum = LocationConfig.judgeDistanceNum;
      await CustomParamsHelper().createOrUpdate(params);
    } else {
      print("CC1");
      LocationConfig.interval = params.timeInterval;
      LocationConfig.distanceFilter = params.distanceFilter;
      LocationConfig.storyRadiusMax = params.storyRadiusMax;
      LocationConfig.storyRadiusMin = params.storyRadiusMin;
      LocationConfig.judgeUsefulLocation = params.storyKeepingTimeMin;
      LocationConfig.poiSearchInterval = params.poiSearchInterval;
      LocationConfig.pictureRadius = params.pictureRadius;
      LocationConfig.refreshTime = params.refreshHomePageTime;
      LocationConfig.judgeDistanceNum = params.judgeDistanceNum;
    }
    return params;
  }
}
