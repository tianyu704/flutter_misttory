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

import 'locationlist_page.dart';

class LogPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LogPageState();
  }
}

class _LogPageState extends LifecycleState<LogPage> {
  //List<Story> _stories = List<Story>();
  List<Timeline> _timelines = List<Timeline>();
  List<Timeline> _searchTimelines = List<Timeline>();
  Map stateMap = {};
  String versionStr = "";
  bool isSearch = false;

  ///搜索
  TextEditingController _textFieldVC = TextEditingController();
  FocusNode _focusNode = new FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  initData() async {
    ///初次加载需要查询前20条数据
    _timelines = await TimelineHelper().queryAll();
    if (_timelines != null && _timelines.length > 0) {
      setState(() {
        ///none
      });
    }
    await getVersion();
    setState(() {});
  }

  _notifySCurrentPage(value) {
    ///TODO：打碎整体重新开始计算
    print("打碎整体重新开始计算");
    initData();
  }

  _searchText(String text) async {
    _searchTimelines = await TimelineHelper().querySearch(text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("时间轴数据"),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                isSearch = !isSearchgit;
                _searchTimelines =  List<Timeline>();

                _textFieldVC.text = "";
                if (!isSearch) {
                  _focusNode.unfocus();
                } else {
                  FocusScope.of(context).requestFocus(_focusNode);
                }
                setState(() {});
              },
              child: Text(isSearch ? "取消搜索" : "搜索")),
          Offstage(
            offstage: false,
            child: FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => CustomParamsPage()))
                      .then(_notifySCurrentPage);
                },
                child: Text("调整参数")),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Text(versionStr),
          Offstage(
            offstage: !isSearch,
            child: _searchWidget(context),
          ),
          Flexible(
            child: ListView.separated(
              itemBuilder: _buildItem,
              separatorBuilder: _buildSeparator,
              itemCount: isSearch
                  ? _searchTimelines?.length ?? 0
                  : _timelines?.length ?? 0,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchWidget(context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _textFieldVC,
        focusNode: _focusNode,
        enabled: true,
        minLines: 1,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "输入地点名",
        ),
        onEditingComplete: () {
          //TODO:监听输入完成触发
          _focusNode.unfocus();
          debugPrint("===${_textFieldVC.text}");
          if (StringUtil.isNotEmpty(_textFieldVC.text)) {
            _searchText(_textFieldVC.text);
          }
        },
      ),
    );
  }

  Widget _buildSeparator(context, index) {
    return SizedBox(
      height: 10,
    );
  }

  Widget _buildItem(context, index) {
    Timeline item = isSearch ? _searchTimelines[index] : _timelines[index];
    String date = "";
    String date1 = "";
    if (item.startTime != null && item?.endTime != 0) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(item.startTime.toInt());
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
                Text("半径:${item.radius}(m)"),
                Text("poi距离:${item.distance}(m)"),
                Text("poiname：${item.poiName}"),
                Text("poi:${item.poiAddress}"),
                Text("自定义名：${item.customAddress}"),
                //      Text("经纬度:(${location.lon},${location.lat})"),
                Text("开始:$date"),
                Text("停留：${DateUtil.getStayShowTime(item.intervalTime)}"),
                Text("是否是图片：${item.isFromPicture == 1}"),
                Offstage(
                  offstage: isSearch,
                  child: RaisedButton(
                    child: Text("过程点"),
                    onPressed: () {
                      Timeline timeline = Timeline();
                      timeline.startTime = (index < _timelines.length - 1)
                          ? (_timelines[index + 1].endTime)
                          : 0;
                      timeline.endTime = item.startTime;
                      print("${timeline.startTime}-${timeline.endTime}");
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LocationListPage(timeline)));
                    },
                  ),
                )

//              Offstage(
//                offstage:!(stateMap.containsKey(index)? stateMap[index] : false),
//                child:  Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Text("                ==============="),
//                    Text("元素举例"),
//                    Text("坐标:(${item.lat},${item.lon})"),
//                    Text("半径"),
//                    Text("水平精度"),
//                    Text("速度"),
//                    Text("加速度"),
//                    Text("海拔"),
//                    Text("地址"),
//                    Text("日期:$date"),
//                  ],
//                ),
//              ),
              ],
            ),
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LocationListPage(item)));

//            if (stateMap.containsKey(index)) {
//               bool isOpen = stateMap[index];
//               stateMap[index] = !isOpen;
//            } else {
//              stateMap[index] = true;
//            }
            setState(() {
              //none
            });
          },
        ));
  }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionStr = "app版本号：${packageInfo.version}(${packageInfo.buildNumber})";
  }
}
