import 'package:sqflite/sqflite.dart';

import 'base_helper.dart';
import 'package:misstory/models/mslocation.dart';

class LocationHelper extends BaseHelper {

  final String tableName = "Location";
  final String columnId="id";

  static final LocationHelper _instance = new LocationHelper._internal();

  factory LocationHelper() => _instance;

  LocationHelper._internal();

  /// 创建Location一条记录
  Future  createLocation(Mslocation location) async {
    if (location == null) {
      return -1;
    }
    Database db = await getDataBase();
    return  await db.insert(tableName, location.toJson());
  }
  /// 读取库中的全部数据
  /// TODO:根据uid区分用户
  Future <List> findAllLocations() async {
    Database db = await getDataBase();
    List<Map> result = await db.rawQuery('SELECT * FROM $tableName');
    if (result.length > 0) {

      List<Mslocation> list = [];
      result.forEach((item) => list.add(Mslocation.fromJson(item)));
      return list;
    }
    return null;
  }
  ///查询指定一条经纬度记录
  ///按time 区间查询 选一条




}
