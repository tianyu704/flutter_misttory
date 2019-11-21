import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/models/customparams.dart';
import '../db_manager.dart';

class CustomParamsHelper {
  static final CustomParamsHelper _instance =
      new CustomParamsHelper._internal();

  factory CustomParamsHelper() => _instance;

  CustomParamsHelper._internal();

  /// 创建
  Future<bool> createOrUpdate(Customparams params) async {
    if (params != null) {
      await FlutterOrmPlugin.saveOrm(
          DBManager.tableCustomParams, params.toJson());

      print("======${params.toJson()}");
      return true;
    }
    return false;
  }

  /// 删除该表:默认就一条数据
  delete() async {
    await Query(DBManager.tableCustomParams).clear();
  }

  ///查找一条
  Future<Customparams> find() async {
    Map result = await Query(DBManager.tableCustomParams).first();
    if (result != null && result.length > 0) {
      return Customparams.fromJson(Map<String, dynamic>.from(result));
    }
    return null;
  }
}
