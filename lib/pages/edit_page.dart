import 'dart:async';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      body: Column(children: <Widget>[
        descTextField(context),
        tagTextField(context),
        peopleTextField(context),
        locationWidget(context),
        locationMapView(context),
      ]),
    );
  }

  ///地点
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

  ///标签编辑
  Widget tagTextField(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
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
            Positioned(
              left: 10,
              child: Text("标签",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            )
          ],
        ));
  }

  ///地点编辑

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
      height: 180,
      width: double.infinity,
      child: AMapView(
        onAMapViewCreated: (controller) {
          ///``添加坐标点 地图图钉📌
          _controller = controller;

          _controller.addMarker(MarkerOptions(
            position: _currentLatLng,
          ));
//                _subscriptionMap = _controller.mapClickedEvent
//                    .listen((it) => print('地图点击: 坐标: $it'));
          _myLocationStyle = MyLocationStyle(
            strokeColor: Color(0x662196F3),
            radiusFillColor: Color(0x662196F3),
            showMyLocation: false,///false 否则不能显示目标地点为中心点
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

  getShowAddress(Story story) {
    if (StringUtil.isEmpty(story.aoiName)) {
      return StringUtil.isEmpty(story.poiName) ? story.address : story.poiName;
    }
    return story.aoiName;
  }
}
