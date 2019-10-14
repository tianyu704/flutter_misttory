import 'dart:async';

import 'package:amap_base/amap_base.dart';
import 'package:amap_base/src/search/model/poi_result.dart';
import 'package:amap_base/src/search/model/poi_search_query.dart';
import 'package:amap_base/src/search/model/poi_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/person_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/db/helper/tag_helper.dart';
import 'package:misstory/models/person.dart';
import 'package:misstory/models/poilocation.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/models/tag.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/widgets/tag_items_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  ///
  AMapController _controller;
  LatLng _currentLatLng;
  MyLocationStyle _myLocationStyle;

  List personCacheList = [];
  List peoplePreList = [];
  List showPeopleList = [];
  List addPeopleList = [];
  List deletePeopleList = [];

  List tagCacheList = [];
  List tagPreList = [];
  List showTagList = [];
  List addTagList = [];
  List deleteTagList = [];

  ///推荐的地点
  List poiList = [];

  ///选择了推荐的点
  Poilocation pickPoiLocation;

  ///
  String _showTimeStr = "";

  @override
  void initState() {
    super.initState();

    ///数据初始化
    _currentLatLng = LatLng(widget.story.lat, widget.story.lon);
    _descTextFieldVC.text =
        StringUtil.isNotEmpty(widget.story.desc) ? widget.story.desc : "";
    _showTimeStr = DateFormat("MM月dd日 HH:mm").format(
        DateTime.fromMillisecondsSinceEpoch(widget.story.createTime.toInt()));

    ///
    initData();
  }

  initData() async {
    ///
    num storyId = widget.story.id;
    personCacheList = await PersonHelper().queryPersonsByStoryId(storyId);
    if (personCacheList != null && personCacheList.length > 0) {
      for (Person person in personCacheList) {
        if (StringUtil.isNotEmpty(person.name)) {
          showPeopleList.add(person.name);
          peoplePreList.add(person.name);
        }
      }
    }
    tagCacheList = await TagHelper().queryTagsByStoryId(storyId);
    if (tagCacheList != null && tagCacheList.length > 0) {
      for (Tag tag in tagCacheList) {
        if (StringUtil.isNotEmpty(tag.tagName)) {
          showTagList.add(tag.tagName);
          tagPreList.add(tag.tagName);
        }
      }
    }
    getPoi();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
//        AppBar(
//          title: Text("编辑"),
//          actions: <Widget>[
//            IconButton(icon: Icon(Icons.save), onPressed: clickSave)
//          ],
//        ),

            AppBar(
          leading: RawMaterialButton(
            shape: CircleBorder(
                side: BorderSide(
              color: Colors.white,
            )),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              '取消',
              style: AppStyle.navCancelText(context),
            ),
          ),
          title: Text(_showTimeStr, style: AppStyle.mainText17(context)),
          centerTitle: true,
          backgroundColor: AppStyle.colors(context).colorBgPage,
          elevation: 0,
          actions: <Widget>[
            RawMaterialButton(
              onPressed: clickSave,
              child: Text('保存', style: AppStyle.navSaveText(context)),
              shape: CircleBorder(
                  side: BorderSide(
                color: Colors.white,
              )),
            ),
          ],
        ),
        backgroundColor: AppStyle.colors(context).colorBgPage,
        body: ListView(
          children: <Widget>[
            descTextField(context),
//            tagTextField(context),
//            peopleTextField(context),
            locationWidget(context),
            locationMapView(context),
            Offstage(
              offstage: poiList == null || poiList.length == 0,
              child: poiSectionWidget(context),
            ),
            Offstage(
              offstage: poiList == null || poiList.length == 0,
              child: poiListWidget(context),
            ),
          ],
        ));
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

  ///标签编辑
  Widget tagTextField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
            child: Text("标签",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Expanded(
            flex: 3,
            child: TagItemsWidget(
              placeholder: "输入标签",
              list: showTagList,
              finishedAction: addTargetTag,
              clickTagItemCallAction: deleteTargetTag,
            ),
          ),
        ],
      ),
    );
  }

  ///人物编辑
  Widget peopleTextField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 10, 0),
            child: Text("人物",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Expanded(
            flex: 1,
            child: TagItemsWidget(
              placeholder: "输入好友",
              list: showPeopleList,
              finishedAction: addTargetPeople,
              clickTagItemCallAction: deleteTargetPeople,
            ),
          ),
        ],
      ),
    );
  }

  //描述编辑
  Widget descTextField(BuildContext context) {
    return SizedBox(
        height: 154,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.only(left: 24,right: 24),
          child: TextField(
            controller: _descTextFieldVC,
            focusNode: _descFocusNode,
            enabled: true,
            maxLines: 5,
            style: AppStyle.mainText14(context),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: "此刻我想说…",
              hintStyle: AppStyle.placeholderText(context),
              border: UnderlineInputBorder(
                borderSide: BorderSide(style: BorderStyle.none,
                  color: Colors.green
                )
              )
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

  Widget poiSectionWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          child: Stack(
            alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              Positioned(
                left: 0.0,
                child: Text("可能是下面的地点？",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              Positioned(
                  right: 0.0,
                  child: IconButton(
                      icon: Icon(Icons.search), onPressed: clickSave))
            ],
          ),
          padding: EdgeInsets.all(15),
        ),
        Container(
          color: Colors.black12,
          padding: EdgeInsets.all(1),
        ),
      ],
    );
  }

  Widget poiListWidget(BuildContext context) {
    List<Widget> widgets = [];
    for (Poilocation p in poiList) {
      if (StringUtil.isNotEmpty(p.title)) widgets.add(poiCell(p));
    }

    Widget content = Wrap(
        verticalDirection: VerticalDirection.down,
        alignment: WrapAlignment.start,
        spacing: 8.0,
        // gap between adjacent chips
        runSpacing: 4.0,
        // gap between lines
        direction: Axis.horizontal,
        //方向
        children: widgets);
    return content;
  }

  Widget poiCell(Poilocation p) {
    String poiName = p.title;
    final size = MediaQuery.of(context).size;
    return InkWell(
      child: SizedBox(
          width: size.width,
          height: 50.0,
          child: Padding(
            child: Text(poiName),
            padding: EdgeInsets.all(15),
          )),
      onTap: () {
        clickPOI(p);
      },
    );
  }

  getPoi() async {
    LatLng latLng = LatLng(widget.story.lat, widget.story.lon);

    PoiResult poiResult = await AMapSearch().searchPoiBound(
      PoiSearchQuery(
        query: "",
        location: latLng,

        /// iOS必须
        searchBound: SearchBound(
          center: latLng,
          range: 100,

          ///兴趣点范围阈值📌TODO：暂定1000m
        ),

        /// Android必须
      ),
    );
    print("${poiResult.toString()}");
    poiResult.pois.reversed
        .forEach((item) => poiList.add(Poilocation.fromJson(item.toJson())));
    if (poiList != null && poiList.length > 0) {
      setState(() {});
    }
  }

  clickPOI(Poilocation location) {
    pickPoiLocation = location;
    //_currentLatLng = LatLng(location.latLonPoint.latitude, location.latLonPoint.longitude);
    setState(() {});
  }

  deleteTargetPeople(String name) {
    deletePeopleList.add(name);
    showPeopleList.remove(name);
    setState(() {});
  }

  addTargetPeople(String name) {
    if (showPeopleList.contains(name)) {
      Fluttertoast.showToast(msg: "好友已添加");
    } else {
      addPeopleList.add(name);
      showPeopleList.add(name);
      setState(() {});
    }
  }

  deleteTargetTag(String name) {
    deleteTagList.add(name);
    showTagList.remove(name);
    setState(() {});
  }

  addTargetTag(String name) {
    if (showTagList.contains(name)) {
      Fluttertoast.showToast(msg: "标签已添加");
    } else {
      addTagList.add(name);
      showTagList.add(name);
      setState(() {});
    }
  }

  ///保存编辑页面数据
  clickSave() {
    //TODO:
    bool isFlag = false;
    Story story = widget.story;

    ///备注保存
    if (StringUtil.isNotEmpty(_descTextFieldVC.text)) {
      story.desc = _descTextFieldVC.text;
      StoryHelper().updateStoryDesc(story);
      isFlag = true;
    }

    ///标签保存
    for (String name in addTagList) {
      if (!tagPreList.contains(name)) {
        TagHelper().createTag(TagHelper().createTagWithName(name, story.id));
        isFlag = true;
      }
    }
    for (String name in deleteTagList) {
      if (tagPreList.contains(name)) {
        int index = tagPreList.indexOf(name);
        Tag deleteObj = tagCacheList[index];
        TagHelper().deleteTag(deleteObj);
        isFlag = true;
      }
    }

    ///人物保存
    for (String name in addPeopleList) {
      if (!peoplePreList.contains(name)) {
        PersonHelper()
            .createPerson(PersonHelper().createPersonWithName(name, story.id));
        isFlag = true;
      }
    }
    for (String name in deletePeopleList) {
      if (peoplePreList.contains(name)) {
        int index = peoplePreList.indexOf(name);
        Person deleteObj = personCacheList[index];
        PersonHelper().deletePerson(deleteObj);
        isFlag = true;
      }
    }

    ///自定义地点保存
    if (pickPoiLocation != null &&
        StringUtil.isNotEmpty(pickPoiLocation.title)) {
      story.customAddress = pickPoiLocation.title;
      StoryHelper().updateCustomAddress(story);
      isFlag = true;

      ///存储该pick 点 如果没存过的话

    }

    ///返回
    if (isFlag) {
      Navigator.pop(context);
    }
  }

  getShowAddress(Story story) {
    if (pickPoiLocation != null &&
        StringUtil.isNotEmpty(pickPoiLocation.title)) {
      return pickPoiLocation.title;
    }
    if (StringUtil.isNotEmpty(story.customAddress)) {
      return story.customAddress;
    }
    if (StringUtil.isEmpty(story.aoiName)) {
      return StringUtil.isEmpty(story.poiName) ? story.address : story.poiName;
    }
    return story.aoiName;
  }
}
