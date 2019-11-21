import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/style/app_style.dart';
import 'customparams_page.dart';
import 'package:misstory/models/story.dart';

class LogPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LogPageState();
  }
}

class _LogPageState extends LifecycleState<LogPage> {
  List<Story> _stories = List<Story>();
  Map stateMap = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  initData() async {
    _stories = await StoryHelper().queryMoreHistories();
    if (_stories != null && _stories.length > 0) {
      setState(() {
        ///none
      });
    }
  }
  _notifySCurrentPage (value) {
      ///TODO：打碎整体重新开始计算
    print("打碎整体重新开始计算");
    initData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("SettingDetail"),
        actions: <Widget>[
          Offstage(
            offstage: false,
            child: FlatButton(
                onPressed: () {

                  Navigator.of(context)
                      .push(MaterialPageRoute(
                      builder: (context) => CustomParamsPage()))
                      .then(_notifySCurrentPage);

//                  Navigator.of(context)
//                      .push(MaterialPageRoute(builder: (context) {
//                    return CustomParamsPage();
//                  }));

                },
                child: Text("settings")),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.separated(
              itemBuilder: _buildItem,
              separatorBuilder: _buildSeparator,
              itemCount: _stories?.length ?? 0,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator(context, index) {
    return SizedBox(
      height: 10,
    );
  }

  Widget _buildItem(context, index) {
    Story item = _stories[index];
    String date = "";
    if (item.updateTime != null && item?.updateTime != 0) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(item.updateTime.toInt());
      date = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
    }
    return Card(
        clipBehavior: Clip.antiAlias,
      color: AppStyle.colors(context).colorBgCard,
      elevation: 0.1,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("中心:(${item.lat},${item.lon})"),
              Text("半径:"),
              Text("精度:"),
              Text("poi:${item.poiName}"),
              Text("地址：${item.defaultAddress}"),
              //      Text("经纬度:(${location.lon},${location.lat})"),
              Text("日期:$date"),
              Offstage(
                offstage:!(stateMap.containsKey(index)? stateMap[index] : false),
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("                ==============="),
                    Text("元素举例"),
                    Text("坐标:(${item.lat},${item.lon})"),
                    Text("半径"),
                    Text("水平精度"),
                    Text("速度"),
                    Text("加速度"),
                    Text("海拔"),
                    Text("地址"),
                    Text("日期:$date"),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: (){
            if (stateMap.containsKey(index)) {
               bool isOpen = stateMap[index];
               stateMap[index] = !isOpen;
            } else {
              stateMap[index] = true;
            }
            setState(() {
              //none
            });
        },
      )
    );
  }
}
