import 'package:sqflite/sqflite.dart';
import '../db_manager.dart';


abstract class BaseHelper {
  Future<Database> getDataBase() async {
    return await DBManager.getCurrentDatabase();
  }
}
