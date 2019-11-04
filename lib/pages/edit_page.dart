import 'dart:async';

import 'package:amap_base/amap_base.dart';
import 'package:amap_base/src/search/model/poi_result.dart';
import 'package:amap_base/src/search/model/poi_search_query.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/db/helper/person_helper.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/db/helper/tag_helper.dart';
import 'package:misstory/main.dart';
import 'package:misstory/models/coord_type.dart';
import 'package:misstory/models/person.dart';
import 'package:misstory/models/poilocation.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/models/tag.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/widgets/my_appbar.dart';
import 'package:misstory/widgets/tag_items_widget.dart';
import 'package:misstory/net/http_manager.dart' as http;
//import 'package:fluttertoast/fluttertoast.dart';

import '../location_config.dart';

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

  ///搜索
  TextEditingController _searchVC = TextEditingController();
  FocusNode _searchNode = new FocusNode();

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
  List poiPreList = [];
  bool isSearching = false;
  bool isPoiNone = false;
  bool isPoiSearchNone = false;
  bool isPoiFirstLoad = true;

  ///选择了推荐的点
  Poilocation pickPoiLocation;

  ///
  String _showTimeStr = "";

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    ///数据初始化
    _currentLatLng = LatLng(widget.story.lat, widget.story.lon);
    if (widget.story.coordType == "WGS84") {
      CalculateTools()
          .convertCoordinate(
              lat: widget.story.lat,
              lon: widget.story.lon,
              type: LatLngType.gps)
          .then((v) {
        _currentLatLng = v;
        _controller?.clearMarkers();
        _controller?.addMarker(MarkerOptions(
          position: _currentLatLng,
        ));
      });
    }
    _descTextFieldVC.text =
        StringUtil.isNotEmpty(widget.story.desc) ? widget.story.desc : "";
    _showTimeStr = DateFormat("MM月dd日 HH:mm").format(
        DateTime.fromMillisecondsSinceEpoch(widget.story.createTime.toInt()));
    _searchVC.addListener(() {
      print(_searchVC.text);
      handleSearchAction();
    });

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
    _searchVC.dispose();
    _descTextFieldVC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isNonePoiList = poiList == null || poiList.length == 0;
    return Scaffold(
      appBar: MyAppbar(
        context,
        title: Text(_showTimeStr, style: AppStyle.mainText17(context)),
        leftText: MaterialButton(
          padding: EdgeInsets.all(0),
          shape: CircleBorder(
            side: BorderSide(
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            '取消',
            style: AppStyle.navCancelText(context),
          ),
        ),
        rightText: MaterialButton(
          padding: EdgeInsets.all(0),
          onPressed: clickSave,
          child: Text('保存', style: AppStyle.navSaveText(context)),
          shape: CircleBorder(
            side: BorderSide(
              color: Colors.white,
            ),
          ),
        ),
      ),
      backgroundColor: AppStyle.colors(context).colorBgPage,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            elevation: 0,
            floating: true,
            bottom: PreferredSize(
              child: Column(
                children: <Widget>[
                  locationWidget(context),
                  locationMapView(context),
                  Offstage(
                    offstage: isSearching,
                    child: poiSectionWidget(context),
                  ),
                  Offstage(
                    offstage: !isSearching,
                    child: searchWidget(context),
                  ),
                ],
              ),
              preferredSize: Size(double.infinity, 317),
            ),
            centerTitle: true,
            expandedHeight: 461,
            leading: Text(""),
            backgroundColor: AppStyle.colors(context).colorBgPage,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: descTextField(context),
            ),
          ),
          getListTargetWidget(context, isNonePoiList),
        ],
      ),
    );
  }

  //组织显示的列表部分
  Widget getListTargetWidget(BuildContext context, bool isNonePoiList) {
    if (isNonePoiList) {
      if (isPoiFirstLoad) {
        return SliverToBoxAdapter(child: SizedBox(height: 0));
      }
      return isSearching
          ? showEmptyWidget(context, "抱歉未找到相关地点", false)
          : showEmptyWidget(context, "你好像处在离线状态", true);
    } else {
      return SliverList(
        delegate: new SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            //创建列表项
            return poiCell(index);
          },
          childCount: poiList?.length ?? 0,
        ),
      );
    }
  }

  /// 地点搜索
  Widget searchWidget(BuildContext context) {
    Color fillColor = AppStyle.colors(context).colorTextFieldLine;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(left: 24, right: 0, top: 10, bottom: 0),
              child: TextField(
                controller: _searchVC,
                focusNode: _searchNode,
                enabled: true,
                maxLines: 1,
                style: TextStyle(
                    color: AppStyle.colors(context).colorLocationText,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: fillColor,
                  hintText: "搜索",
                  hintStyle: AppStyle.placeholderText(context),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      "assets/images/icon_search.svg",
                    ),
                  ),
                  contentPadding: EdgeInsets.only(top: 0, right: 15, bottom: 0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(38.0),
                      borderSide: BorderSide.none),
                ),
                onEditingComplete: handleSearchFinished,
              ),
            ),
          ),
        ),
        SizedBox(
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: MaterialButton(
              padding: EdgeInsets.all(0),
              shape: CircleBorder(
                side: BorderSide(
                  color: Colors.white,
                ),
              ),
              onPressed: handleCancel,
              child: Text(
                '取消',
                style: AppStyle.mainText14(context),
              ),
            ),
          ),
          width: 60,
          height: 48,
        ),
      ],
    );
  }

  ///地点编辑
  Widget locationWidget(BuildContext context) {
    return InkWell(
        child: SizedBox(
      height: 48,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: SvgPicture.asset(
                StringUtil.isEmpty(widget.story.customAddress)
                    ? "assets/images/icon_location_empty.svg"
                    : "assets/images/icon_location_fill.svg",
                width: 14,
                height: 14,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10, bottom: 1),
                child: Text(getShowAddress(widget.story),
                    style: AppStyle.locationText14(context)),
              ),
            ),
          ],
        ),
      ),
    )

//      onTap: () {
//        //TODO:
//      },
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
        height: 144,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.only(left: 24, right: 24),
          child: TextField(
            controller: _descTextFieldVC,
            focusNode: _descFocusNode,
            enabled: true,
            maxLines: 7,
            cursorWidth: 2,
            cursorRadius: Radius.circular(1),
            scrollPhysics: BouncingScrollPhysics(),
            autocorrect: true,
            style: AppStyle.mainText14(context),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: "此刻我想说…",
              hintStyle: AppStyle.placeholderText(context),
//                border: InputBorder.none
              border: UnderlineInputBorder(
                  borderSide: BorderSide(
                style: BorderStyle.solid,
                color: AppStyle.colors(context).colorTextFieldLine,
              )),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                style: BorderStyle.solid,
                color: AppStyle.colors(context).colorPrimary,
              )),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                style: BorderStyle.solid,
                color: AppStyle.colors(context).colorTextFieldLine,
              )),
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
    return Stack(
      children: <Widget>[
        locationMapView1(context),
        Positioned(
          bottom: 10.0,
          right: 8.0,
           width: 45,
          height: 45,
          child: RaisedButton(
            color: AppStyle.colors(context).colorBgPage,
            colorBrightness: Brightness.dark,
            splashColor: Colors.grey,
            child: SvgPicture.asset(
              "assets/images/icon_location_delete.svg",
              width: 18,
              height: 18,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(45 / 2)),
            onPressed: clickDeleteStory,
          ),
        ),
      ],
    );
  }

  Widget locationMapView1(BuildContext context) {
    return SizedBox(
      height: 220,
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
          _controller.setZoomLevel(10);
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
    return InkWell(
      onTap: showSearch,
      child: SizedBox(
        height: 49,
        width: double.infinity,
        child: Column(
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
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppStyle.colors(context).colorMainText)),
                  ),
                  Positioned(
                      right: 0.0,
                      child: IconButton(
                          icon: SvgPicture.asset(
                            "assets/images/icon_search.svg",
                            width: 18,
                            height: 18,
                          ),
                          onPressed: showSearch))
                ],
              ),
              padding: EdgeInsets.fromLTRB(30, 14, 10, 14),
            ),
            Container(
              height: 1,
              margin: EdgeInsets.only(left: 24, right: 24),
              color: AppStyle.colors(context).colorTextFieldLine,
            ),
          ],
        ),
      ),
    );
  }

  Widget poiCell(int index) {
    Poilocation p = poiList[index];
    String poiName = p.title;
    String subName = StringUtil.isNotEmpty(p.snippet) ? p.snippet : "";
    return Padding(
      padding: EdgeInsets.only(bottom: index == poiList.length - 1 ? 37 : 0),
      child: InkWell(
        onTap: () {
          clickPOI(p);
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
          ),
          child: Row(
            children: <Widget>[
              SvgPicture.asset(
                "assets/images/icon_poi_item.svg",
                width: 20,
                height: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 8),
                      child: Text(
                        poiName,
                        maxLines: 2,
                        style: AppStyle.locationText14(context),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, top: 1, bottom: 8),
                      child: Text(
                        subName,
                        style: AppStyle.descText12(context),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showEmptyWidget(BuildContext context, String title, bool isEnable) {
    return SliverToBoxAdapter(
      child: InkWell(
        onTap: isEnable
            ? () {
                getPoi();
              }
            : null,
        child: Padding(
          padding: EdgeInsets.only(top: 30, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                "assets/images/icon_poi_none.svg",
                width: 102,
                height: 72,
              ),
              Text(title,
                  style: TextStyle(
                      color: AppStyle.colors(context).colorDescText,
                      fontSize: 14)),
              SizedBox(
                height: 5,
              ),
              Text("请点击重试",
                  style: TextStyle(
                      color: AppStyle.colors(context).colorDescText,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  showSearch() {
    _scrollController.jumpTo(0);
    _scrollController.jumpTo(144);
//    _scrollController.animateTo(154,
//        duration: Duration(seconds: 1), curve: Curves.linear);
    isSearching = true;
    FocusScope.of(context).requestFocus(_searchNode);
    setState(() {});
  }

  ///搜索取消
  handleCancel() {
    _searchVC.text = "";
    _searchNode.unfocus();
    isSearching = false;
    getPoi();
  }

  ///搜索完成
  handleSearchFinished() {
    _searchNode.unfocus();
  }

  ///搜素触发方法
  handleSearchAction() async {
    String searchText = _searchVC.text;
    debugPrint("===$searchText");
    if (StringUtil.isEmpty(searchText)) {
      return;
    }
    if (isInChina()) {
      LatLng latLng = LatLng(widget.story.lat, widget.story.lon);
      PoiResult poiResult = await AMapSearch().searchPoiBound(
        PoiSearchQuery(
          query: searchText,
          location: latLng,

          /// iOS必须
          searchBound: SearchBound(
            center: latLng,
            range: LocationConfig.poiSearchInterval,

            ///兴趣点范围阈值📌
          ),

          /// Android必须
        ),
      );
      List list = [];
      poiResult.pois
          .forEach((item) => list.add(Poilocation.fromJson(item.toJson())));
      poiList = list;
    } else {
      print("start......");
      poiList = await http.requestLocations(
          latlon: "${widget.story.lat}, ${widget.story.lon}", near: searchText);
    }

    if (poiList != null && poiList.length > 0) {
      isSearching = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  getPoi() async {
    if (poiPreList != null && poiPreList.length > 0 && !isSearching) {
      poiList = poiPreList;
      setState(() {});
      return;
    }

    if (isInChina()) {
      LatLng latLng = LatLng(widget.story.lat, widget.story.lon);
      PoiResult poiResult = await AMapSearch().searchPoiBound(
        PoiSearchQuery(
          query: "",
          location: latLng,

          /// iOS必须
          searchBound: SearchBound(
            center: latLng,
            range: LocationConfig.poiSearchInterval,

            ///兴趣点范围阈值📌TODO：暂定1000m
          ),

          /// Android必须
        ),
      );
      List list = [];
      poiResult.pois
          .forEach((item) => list.add(Poilocation.fromJson(item.toJson())));
      poiPreList = list;
    } else {
      poiPreList = await http.requestLocations(
          latlon: "${widget.story.lat}, ${widget.story.lon}");
    }
    if (!isSearching) {
      poiList = poiPreList;
      isPoiFirstLoad = false;
      if (poiList != null && poiList.length > 0) {
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  bool isInChina() {
    return (CoordType.aMap == widget.story.coordType) ||
        ("中国" == widget.story.country) ||
        ("China" == widget.story.country);
  }

  clickPOI(Poilocation location) {
    pickPoiLocation = location;
    _currentLatLng =
        LatLng(location.latLonPoint.latitude, location.latLonPoint.longitude);
    _controller.clearMarkers();
    _controller.addMarker(MarkerOptions(
      position: _currentLatLng,
    ));
    setState(() {});
  }

  deleteTargetPeople(String name) {
    deletePeopleList.add(name);
    showPeopleList.remove(name);
    setState(() {});
  }

  addTargetPeople(String name) {
    if (showPeopleList.contains(name)) {
      //Fluttertoast.showToast(msg: "好友已添加");
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
      //  Fluttertoast.showToast(msg: "标签已添加");
    } else {
      addTagList.add(name);
      showTagList.add(name);
      setState(() {});
    }
  }
  ///删除当前story
  clickDeleteStory() async{
    Story story = widget.story;
    if (story.id != null) {
      await StoryHelper().deleteTargetStoryWithStoryId(story.id);
    }
    await LocationHelper().deleteTargetLocationWithTime(story.createTime, story.updateTime);
    debugPrint("删除完毕");
    Navigator.pop(context,story);
  }
  ///保存编辑页面数据
  clickSave() async {
    //TODO:
    Story story = widget.story;
    if (story.id == null) {
      //TODO:创建一条story
      story.id = await StoryHelper().createStory(story);
    }

    ///备注保存
    story.desc = _descTextFieldVC.text ?? "";
    await StoryHelper().updateStoryDesc(story);

//    ///标签保存
//    for (String name in addTagList) {
//      if (!tagPreList.contains(name)) {
//        TagHelper().createTag(TagHelper().createTagWithName(name, story.id));
//        isFlag = true;
//      }
//    }
//    for (String name in deleteTagList) {
//      if (tagPreList.contains(name)) {
//        int index = tagPreList.indexOf(name);
//        Tag deleteObj = tagCacheList[index];
//        TagHelper().deleteTag(deleteObj);
//        isFlag = true;
//      }
//    }
//
//    ///人物保存
//    for (String name in addPeopleList) {
//      if (!peoplePreList.contains(name)) {
//        PersonHelper()
//            .createPerson(PersonHelper().createPersonWithName(name, story.id));
//        isFlag = true;
//      }
//    }
//    for (String name in deletePeopleList) {
//      if (peoplePreList.contains(name)) {
//        int index = peoplePreList.indexOf(name);
//        Person deleteObj = personCacheList[index];
//        PersonHelper().deletePerson(deleteObj);
//        isFlag = true;
//      }
//    }

    ///自定义地点保存
    Map<num, Story> stories;
    if (pickPoiLocation != null &&
        StringUtil.isNotEmpty(pickPoiLocation.title)) {
      story.customAddress = pickPoiLocation.title;
      story.lat = pickPoiLocation.latLonPoint.latitude;
      story.lon = pickPoiLocation.latLonPoint.longitude;
      stories = await StoryHelper().updateCustomAddress(story);

      ///存储该pick 点 如果没存过的话
    }
    Navigator.pop(context, [stories]);
  }

  getShowAddress(Story story) {
    if (pickPoiLocation != null &&
        StringUtil.isNotEmpty(pickPoiLocation.title)) {
      return pickPoiLocation.title;
    }
    if (StringUtil.isNotEmpty(story.customAddress)) {
      return story.customAddress;
    }
    return story.defaultAddress;
  }
}
