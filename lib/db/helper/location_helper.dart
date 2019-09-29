import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/db/db_manager.dart';
import 'package:misstory/models/mslocation.dart';

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

  ///查询指定一条经纬度记录
  ///按time 区间查询 选一条

}
