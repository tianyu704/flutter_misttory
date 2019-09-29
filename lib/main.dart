import 'package:amap_base_map/amap_base_map.dart';
import 'package:flutter/material.dart';
import 'package:misstory/pages/home_page.dart';
import 'package:flutter_amap_location_plugin/amap_location_lib.dart';
import 'package:misstory/db/db_manager.dart';

void main() async {
  /// 初始化数据库
  await DBManager.init();
  await AMap.init('11bcf7a88c8b1a9befeefbaa2ceaef71');
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Misstory',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
