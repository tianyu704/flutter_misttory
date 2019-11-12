import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/models/poilocation.dart';

import '../db_manager.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-11-11
///
class ConfirmPoiHelper {
  static final ConfirmPoiHelper _instance = new ConfirmPoiHelper._internal();

  factory ConfirmPoiHelper() => _instance;

  ConfirmPoiHelper._internal();

  Future createPoi(Poilocation poilocation) async {
    if (poilocation != null) {
      await FlutterOrmPlugin.saveOrm(
          DBManager.tableConfirmPoi, poilocation.toJson());
    }
  }

  Future queryPoi(String uuid) async {
    Map result = await Query(DBManager.tableConfirmPoi).whereByColumFilters([
      WhereCondiction("story_uuid", WhereCondictionType.IN, [uuid])
    ]).first();
    if (result != null) {
      return Poilocation.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }
}
