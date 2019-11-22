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
  /// 2个相邻且相同的地点之间的时间间隔，超过该时间算作一个点，没超过就合并
  static num intervalGap = 60 * 1000 * 30;

  /// 地点经纬度最小半径
  static num locationRadius = 100;
  /// 地点经纬度最大半径
  static num locationMaxRadius = 200;


  ///高德poi类型
  /// 010000汽车服务、020000汽车销售、030000汽车维修、050000餐饮服务、060000购物服务、
  /// 070000生活服务、080000体育休闲、090000医疗保健服务、100000住宿服务、110000风景名胜
  /// 120000商务住宅、130000政府机构及社会团体、140000科教文化、150000交通设施、
  /// 160000金融保险、170000公司企业、180000道路附属设施、190000地名地址信息、200000公共设施
  ///220000事件活动、990000同行设施
  static String aMapTypes = "120000|050000|110000";


  static resetData() async {
    LocationConfig.interval = 60 * 1000 * 3;
    LocationConfig.distanceFilter = 1000;
    LocationConfig.locationMaxRadius = 200;
    LocationConfig.locationRadius = 100;
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
      params.storyRadiusMax = LocationConfig.locationMaxRadius;
      params.storyRadiusMin = LocationConfig.locationRadius;
      params.storyKeepingTimeMin = LocationConfig.judgeUsefulLocation;
      params.poiSearchInterval = LocationConfig.poiSearchInterval;
      params.pictureRadius = LocationConfig.pictureRadius;
      params.refreshHomePageTime = LocationConfig.refreshTime;
      params.judgeDistanceNum = LocationConfig.judgeDistanceNum;
      params.aMapTypes = LocationConfig.aMapTypes;
      await CustomParamsHelper().createOrUpdate(params);
    } else {
      print("CC1");
      LocationConfig.interval = params.timeInterval;
      LocationConfig.distanceFilter = params.distanceFilter;
      LocationConfig.locationMaxRadius = params.storyRadiusMax;
      LocationConfig.locationRadius = params.storyRadiusMin;
      LocationConfig.judgeUsefulLocation = params.storyKeepingTimeMin;
      LocationConfig.poiSearchInterval = params.poiSearchInterval;
      LocationConfig.pictureRadius = params.pictureRadius;
      LocationConfig.refreshTime = params.refreshHomePageTime;
      LocationConfig.judgeDistanceNum = params.judgeDistanceNum;
      LocationConfig.aMapTypes = params.aMapTypes;
    }
    return params;
  }
}
