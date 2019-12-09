import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/timeline_helper.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:package_info/package_info.dart';
import 'customparams_page.dart';
import 'package:misstory/models/timeline.dart';
import 'package:misstory/utils/date_util.dart';
import 'package:path_provider/path_provider.dart';

class iOSPage extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _iOSPageState();
  }
}

class _iOSPageState extends LifecycleState<iOSPage> {
  String content = "";

  @override
  void initState() {
    // TODO: implement initState
    initData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build


    return Scaffold(
        appBar: AppBar(
        title: Text("时间轴数据"),
        ),

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        reverse: true,
        padding: EdgeInsets.all(0.0),
        physics: BouncingScrollPhysics(),
        child:  Text("${StringUtil.isNotEmpty(content) ? content : "暂无内容"}",style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold)),
    ));
   // return ;
  }

  initData() async {
    content = await readCounter();
    setState(() {

    });
  }

  Future<String> get _localPath async {
    final _path = await getApplicationDocumentsDirectory();
    return _path.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/testiOSLogs.text');
  }

  Future<String> readCounter() async {
    final file = await _localFile;
    var contents = await file.readAsString();
    return contents;
  }
}
