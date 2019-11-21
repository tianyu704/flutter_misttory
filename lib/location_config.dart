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
  static num interval = 60 * 1000 * 3;

  /// 每隔distanceFilter米定位一次
  static num distanceFilter = 1000;

  /// 停留时长>judgeUsefulLocation毫秒的点算作一个story
  static num judgeUsefulLocation = 3 * 60 * 1000;

  /// 首页每隔多久刷新一次最新页面显示数据
  static num refreshTime = 60;

  /// poi搜索范围半径
  static num poiSearchInterval = 1000;

  /// 图片经纬度半径,判断是否在同一位置
  static num pictureRadius = 100;

  /// 地点经纬度半径,判断是否在同一位置
  static final locationRadius = 100;
  static  num storyRadiusMin = 10;
  static  num storyRadiusMax = 200;

  static resetData() async {
    LocationConfig.interval =  60 * 1000 * 3;
    LocationConfig.distanceFilter =  1000;
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
      params.pictureRadius =LocationConfig.pictureRadius;
      params.refreshHomePageTime = LocationConfig.refreshTime;
      params.judgeDistanceNum = LocationConfig.judgeDistanceNum;
      await CustomParamsHelper().createOrUpdate(params);
    } else {
      print("CC1");
      LocationConfig.interval =  params.timeInterval.toInt();
      LocationConfig.distanceFilter = params.distanceFilter.toInt();
      LocationConfig.storyRadiusMax = params.storyRadiusMax.toInt();
      LocationConfig.storyRadiusMin = params.storyRadiusMin;
      LocationConfig.judgeUsefulLocation = params.storyKeepingTimeMin .toInt();
      LocationConfig.poiSearchInterval = params.poiSearchInterval.toInt();
      LocationConfig.pictureRadius = params.pictureRadius.toInt();
      LocationConfig.refreshTime = params.refreshHomePageTime.toInt();
      LocationConfig.judgeDistanceNum = params.judgeDistanceNum.toInt();
    }
    return params;
  }
}



