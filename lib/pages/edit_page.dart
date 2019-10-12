import 'dart:async';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/person_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/db/helper/tag_helper.dart';
import 'package:misstory/models/person.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/models/tag.dart';
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
  ///

  @override
  void initState() {
    super.initState();

    ///数据初始化
    _currentLatLng = LatLng(widget.story.lat, widget.story.lon);
    _descTextFieldVC.text =
        StringUtil.isNotEmpty(widget.story.desc) ? widget.story.desc : "";
    ///
    initData();
  }

  initData () async {
    ///
    num storyId = widget.story.id;
    personCacheList = await PersonHelper()
        .queryPersonsByStoryId(storyId);
    if (personCacheList != null && personCacheList.length > 0 ) {
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
          actions: <Widget>[
            IconButton(icon: Icon(Icons.save), onPressed: clickSave)
          ],
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
            child:  Text("标签",
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
            child:  Text("人物",
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
      StoryHelper().updateCustomAddress(story);
      isFlag = true;
    }
    ///标签保存
    for (String name in addTagList) {
      if (!tagPreList.contains(name)) {
        TagHelper().createTag(TagHelper().createTagWithName(name,story.id));
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
          PersonHelper().createPerson(PersonHelper().createPersonWithName(name,story.id));
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


    ///地点保存
    ///返回
    if (isFlag) {
      Navigator.pop(context);
    }
  }

  getShowAddress(Story story) {
    if (StringUtil.isEmpty(story.aoiName)) {
      return StringUtil.isEmpty(story.poiName) ? story.address : story.poiName;
    }
    return story.aoiName;
  }
}
