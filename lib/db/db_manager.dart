import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

///
/// Create by Liqun
/// Date: 2019-09-26
///
class DBManager {
  static const _dbName = "flutter_misstory_app.db";
  static const _version = 1;
  static Database _database;

  ///初始化
  static init() async {
    // open the database
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbName);
    File file = File(path);

    if (!(await file.exists())) {
      file.create(recursive: true);
    }
    _database = await openDatabase(
      path,
      version: _version,
      onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(
            "CREATE TABLE Location (id INTEGER PRIMARY KEY, altitude REAL , speed REAL , bearing REAL , citycode TEXT, adcode TEXT, country TEXT, province TEXT, city TEXT, district TEXT, road TEXT, street TEXT, number TEXT, poiname TEXT, errorCode REAL , errorInfo TEXT, locationType REAL , locationDetail  TEXT, aoiname TEXT, address TEXT, poiid TEXT, floor TEXT , description TEXT, time REAL , provider TEXT, lon REAL , lat REAL , accuracy REAL , isOffset INTEGER, isFixLastLocation INTEGER, coordType TEXT)");
      },
    );
  }

  /**
   * 表是否存在
   */
  static isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.length > 0;
  }

  ///获取当前数据库对象
  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database;
  }

  ///关闭
  static close() {
    _database?.close();
    _database = null;
  }
}
