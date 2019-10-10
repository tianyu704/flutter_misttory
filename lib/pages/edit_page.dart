import 'dart:async';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:full_icon_button/full_icon_button.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/utils/string_util.dart';

class EditPage extends StatefulWidget {
  final Story story;

  EditPage(this.story);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EditPageState();
  }
}

class _EditPageState extends LifecycleState<EditPage> {
  ///备注
  TextEditingController _descTextFieldVC = TextEditingController();
  FocusNode _descFocusNode = new FocusNode();

  ///人物
  TextEditingController _peopleTextFieldVC = TextEditingController();
  FocusNode _peopleFocusNode = new FocusNode();

  ///标签
  TextEditingController _tagTextFieldVC = TextEditingController();
  FocusNode _tagFocusNode = new FocusNode();

  ///
  AMapController _controller;
  StreamSubscription _subscriptionMap;
  LatLng _currentLatLng;
  MyLocationStyle _myLocationStyle;

  var peopleList = ["测试", "测试1", "测试2", "测试4", "测试5"];

  ///

  @override
  void initState() {
    super.initState();

    ///数据初始化
    _currentLatLng = LatLng(widget.story.lat, widget.story.lon);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("编辑"),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          descTextField(context),
          tagTextField(context),
          peopleTextField(context),
          locationWidget(context),
          locationMapView(context),
        ],
      )
    );
  }

  ///地点编辑
  Widget locationWidget(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("地点",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            Icon(Icons.location_on, size: 17),
            Padding(
              padding: EdgeInsets.only(left: 5),
            ),
            Expanded(
                flex: 1,
                child: Text(getShowAddress(widget.story),
                    style: TextStyle(fontSize: 17))),
          ],
        ),
      ),
      onTap: () {
        //TODO:
      },
    );
  }

  Widget tagTextField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("标签",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Expanded(
            flex: 1,
            child: peopleTags(context, peopleList),
          ),
        ],
      ),
    );
  }

  ///标签编辑
  Widget tagTextField1(BuildContext context) {
    return SizedBox(
        //width: MediaQuery.of(context).size.width,

        child: Stack(
      //alignment: Alignment.center,
      children: <Widget>[
        Text("标签", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        peopleTags(context, peopleList),
        Container(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _tagTextFieldVC,
              focusNode: _tagFocusNode,
              enabled: true,
              minLines: 1,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: "输入标签",
                contentPadding: EdgeInsets.fromLTRB(50, 10, 10, 10),
              ),
              onEditingComplete: () {
                //TODO:
                _tagFocusNode.unfocus();
                //debugPrint("===${_tagTextFieldVC.text}");
              },
            ),
//
          ),
        ),
      ],
    ));
  }

  ///人物编辑
  Widget peopleTextField(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _peopleTextFieldVC,
                  focusNode: _peopleFocusNode,
                  enabled: true,
                  minLines: 1,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "输入好友",
                    contentPadding: EdgeInsets.fromLTRB(50, 10, 10, 10),
                  ),
                  onEditingComplete: () {
                    //TODO:监听点击该行第一响应触发
                    _peopleFocusNode.unfocus();
                    //debugPrint("===${_peopleTextFieldVC.text}");
                  },
                ),
//
              ),
            ),
            Positioned(
              left: 10,
              child: Text("人物",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            )
          ],
        ));
  }

  //描述编辑
  Widget descTextField(BuildContext context) {
    return SizedBox(
        height: 140,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: _descTextFieldVC,
            focusNode: _descFocusNode,
            enabled: true,
            maxLines: 5,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: "备注",
            ),
            onEditingComplete: () {
              //TODO:监听输入完成触发
              _descFocusNode.unfocus();
              //debugPrint("===${_descTextFieldVC.text}");
            },
          ),
//
        ));
  }

  Widget locationMapView(BuildContext context) {
    return SizedBox(
      height: 130,
      width: double.infinity,
      child: AMapView(
        onAMapViewCreated: (controller) {
          ///``添加坐标点 地图图钉📌
          _controller = controller;

          _controller.addMarker(MarkerOptions(
            position: _currentLatLng,
          ));
          _myLocationStyle = MyLocationStyle(
            strokeColor: Color(0x662196F3),
            radiusFillColor: Color(0x662196F3),
            showMyLocation: false,

            ///false 否则不能显示目标地点为中心点
          );
          _controller.setUiSettings(UiSettings(
            isMyLocationButtonEnabled: false,
            logoPosition: LOGO_POSITION_BOTTOM_LEFT,
            isZoomControlsEnabled: false,
          ));
          _controller.setMyLocationStyle(_myLocationStyle);
          _controller.setZoomLevel(16);
        },
        amapOptions: AMapOptions(
          compassEnabled: false,
          zoomControlsEnabled: true,
          logoPosition: LOGO_POSITION_BOTTOM_CENTER,
          camera: CameraPosition(
            target: _currentLatLng,
            zoom: 10,
          ),
        ),
      ),
    );
  }

  Widget peopleTags(BuildContext context, List list) {
    List<Widget> peopleLists = [];
    for (String name in list) {
      peopleLists.add(tagItem(name));
    }
    peopleLists.add(TextField(
      controller: _tagTextFieldVC,
      focusNode: _tagFocusNode,
      enabled: true,
      minLines: 1,

      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: "输入标签",
        contentPadding: EdgeInsets.fromLTRB(50, 10, 10, 10),
      ),
      onEditingComplete: () {
        //TODO:
        _tagFocusNode.unfocus();
        //debugPrint("===${_tagTextFieldVC.text}");
      },
    ));

    Widget content = Wrap(
        spacing: 8.0, // gap between adjacent chips
        runSpacing: 4.0, // gap between lines
        direction: Axis.horizontal, //方向
        children: peopleLists);
    return content;
  }

  //一个标签
  Widget tagItem(String name) {
    return FullIconButton(
      label: Text(
        name,
        style: TextStyle(color: Colors.white),
      ),
      height: 40,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      rightIcon: Icon(Icons.close),
      color: Colors.blue,
      textPadding: EdgeInsets.only(right: 10),
      highlightColor: Colors.lightBlue,elevation: 0,highlightElevation: 0,
      onPressed: (){

      },
    );
  }

  getShowAddress(Story story) {
    if (StringUtil.isEmpty(story.aoiName)) {
      return StringUtil.isEmpty(story.poiName) ? story.address : story.poiName;
    }
    return story.aoiName;
  }
}
