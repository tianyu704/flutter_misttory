///
/// Create by Hugo.Guo
/// Date: 2019-10-10
///
class LocationConfig {
  /// 判断2个点距离是否超出judgeDistanceNum
  static final judgeDistanceNum = 5000;

  /// 每隔interval毫秒定位一次
  static final interval = 60 * 1000 * 5;

  /// 每隔distanceFilter米定位一次
  static final distanceFilter = 1000;

  /// 停留时长>judgeUsefulLocation毫秒的点算作一个story
  static final judgeUsefulLocation = 5 * 60 * 1000;

  /// 首页每隔多久刷新一次最新页面显示数据
  static final refreshTime = 60;
}
