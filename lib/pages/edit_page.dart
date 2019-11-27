import 'dart:async';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/timeline_helper.dart';
import 'package:misstory/models/amap_poi.dart';
import 'package:misstory/models/coord_type.dart';
import 'package:misstory/models/timeline.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/widgets/loading_dialog.dart';
import 'package:misstory/widgets/my_appbar.dart';
import 'package:misstory/widgets/tag_items_widget.dart';
import 'package:misstory/net/http_manager.dart' as http;

import '../location_config.dart';

class EditPage extends StatefulWidget {
  final Timeline timeline;

  EditPage(this.timeline);

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

  ///自定义地址编辑
  TextEditingController _addressTextFieldVC = TextEditingController();
  FocusNode _addressFocusNode = new FocusNode();

  ///是否切换编辑地址模式
  bool isSwitchToEditAddress = false;

  ///搜索
  TextEditingController _searchVC = TextEditingController();
  FocusNode _searchNode = new FocusNode();

  ///
  AMapController _controller;
  LatLng _poiLatLng;
  LatLng _originLatLng;
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
  List<AmapPoi> poiList = [];
  List<AmapPoi> poiPreList = [];
  bool isSearching = false;
  bool isPoiNone = false;
  bool isPoiSearchNone = false;
  bool isPoiFirstLoad = true;

  ///选择了推荐的点
  AmapPoi pickPoi;

  ///
  String _showTimeStr = "";

  ///正在保存中。。。
  bool isSaving = false;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    print("${widget.timeline.poiLocation}");

    _descTextFieldVC.text =
        StringUtil.isNotEmpty(widget.timeline.desc) ? widget.timeline.desc : "";
    _addressTextFieldVC.text = getShowAddress(widget.timeline);
    _showTimeStr = DateFormat("MM月dd日 HH:mm").format(
        DateTime.fromMillisecondsSinceEpoch(widget.timeline.startTime.toInt()));
    _searchVC.addListener(() {
//      print(_searchVC.text);
//      handleSearchAction();
    });
    _originLatLng = LatLng(widget.timeline.lat, widget.timeline.lon);
    initCurrentLatLonConvert();
  }

  initCurrentLatLonConvert() async {
    _originLatLng = await CalculateTools().convertCoordinate(
        lat: widget.timeline.lat,
        lon: widget.timeline.lon,
        type: LatLngType.gps);

    ///数据初始化
    if (StringUtil.isNotEmpty(widget.timeline.poiLocation)) {
      ///TODO 需要用真正poi坐标初始化
      List latlon = widget.timeline.poiLocation.split(",");
      if (latlon.length == 3) {
        double lat = double.tryParse(latlon[1]);
        double lon = double.tryParse(latlon[0]);
        String type = latlon[2] as String;
        if (type == CoordType.gps) {
          _poiLatLng = await CalculateTools()
              .convertCoordinate(lat: lat, lon: lon, type: LatLngType.gps);
        } else {
          _poiLatLng = LatLng(lat, lon);
        }
      }
    } else {
      ///存在空poi的timeLine 有必要该初始化赋值 否则UI错乱
      _poiLatLng = _originLatLng;
    }
    await _controller?.clearMarkers();
    if (_poiLatLng != null) {
      await _controller?.addMarker(MarkerOptions(
        position: _poiLatLng,
      ));
    }
    if (_originLatLng != null) {
      await _controller?.addMarker(MarkerOptions(
        position: _originLatLng,
        icon: "assets/images/icon_location.png",
      ));
    }
    _controller?.zoomToSpan([_poiLatLng, _originLatLng]);
    setState(() {});
    getPoi();
  }

  @override
  void dispose() {
    ///
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
          onPressed: () async {
            await clickSave();
          },
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
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: SvgPicture.asset(
                widget.timeline.isConfirm == 1
                    ? "assets/images/icon_location_fill.svg"
                    : "assets/images/icon_location_empty.svg",
                width: 14,
                height: 14,
              ),
            ),
//            Offstage(
//              offstage: !isSwitchToEditAddress,
//              child: Expanded(
//                child: Padding(
//                  padding: EdgeInsets.only(left: 10, bottom: 1),
//                  child: Text(getShowAddress(widget.story),
//                      style: AppStyle.locationText14(context)),
//                ),
//              ),
//            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10, bottom: 1),
                child: addressTextField(context),
              ),
            ),
            SizedBox(
              width: 44,
              height: 44,
              child: MaterialButton(
                onPressed: handleStartEditAddress,
                padding: EdgeInsets.all(0),
                child: SvgPicture.asset("assets/images/icon_edit.svg"),
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

  ///自定义地址编辑
  Widget addressTextField(BuildContext context) {
    return Container(
//      constraints: BoxConstraints(
//          minWidth: 80,
//          maxWidth: 300
//
//      ),

      child: TextField(
        controller: _addressTextFieldVC,
        focusNode: _addressFocusNode,
        enabled: isSwitchToEditAddress,
        minLines: 1,
        maxLines: 2,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "",
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppStyle.colors(context).colorBgPage),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppStyle.colors(context).colorBgPage),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppStyle.colors(context).colorBgPage),
          ),
        ),
        onEditingComplete: () {
          finishedEditAddress();
        },
        style: AppStyle.locationText14(context), //输入文本的样式,
      ),
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
            onPressed: () {
              _showAlertView(context);
            },
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
        onAMapViewCreated: (controller) async {
          ///``添加坐标点 地图图钉📌
          _controller = controller;
          _controller.setUiSettings(UiSettings(
            isMyLocationButtonEnabled: false,
            logoPosition: LOGO_POSITION_BOTTOM_LEFT,
            isZoomControlsEnabled: false,
          ));
          _myLocationStyle = MyLocationStyle(
            strokeColor: Color(0x662196F3),
            radiusFillColor: Color(0x662196F3),
            //false 否则不能显示目标地点为中心点
            showMyLocation: false,
            myLocationType: LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER,
            interval: 2000000,
          );
          _controller.setMyLocationStyle(_myLocationStyle);
          if (_originLatLng != null) {
            await _controller.addMarker(MarkerOptions(
              position: _originLatLng,
              icon: "assets/images/icon_location.png",
            ));
          }
          if (_poiLatLng != null) {
            await _controller.addMarker(MarkerOptions(
              position: _poiLatLng,
            ));
          }
          _controller.zoomToSpan([_poiLatLng, _originLatLng]);
//          _controller.setZoomLevel(15);
        },
        amapOptions: AMapOptions(
          compassEnabled: false,
          zoomControlsEnabled: true,
          logoPosition: LOGO_POSITION_BOTTOM_CENTER,
          camera: CameraPosition(
            target: _originLatLng,
            bearing: widget.timeline.radius.toDouble(),
            zoom: 15,
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
    AmapPoi p = poiList[index];
    String poiId = p.id;
    String subName =
        "${p.type}-->${StringUtil.isNotEmpty(p.address) ? p.address : ""}";
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
                        p.name,
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
              ),
              Text("${p.distance}m"),
              Offstage(
                offstage: !isShowCheck(poiId),

                ///TODO:待补充判断
                child: Icon(Icons.done),
              )
            ],
          ),
        ),
      ),
    );
  }

  handleStartEditAddress() {
    isSwitchToEditAddress = !isSwitchToEditAddress;
    if (isSwitchToEditAddress) {
      FocusScope.of(context).requestFocus(_addressFocusNode);
      setState(() {});
    } else {
      finishedEditAddress();
    }
  }

  finishedEditAddress() {
    isSwitchToEditAddress = false;
    _addressFocusNode.unfocus();
    print("******");
    String str = _addressTextFieldVC.text;
    if (StringUtil.isEmpty(str)) {
      _addressTextFieldVC.text = getShowAddress(widget.timeline);
    }
    setState(() {});
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
    print(_searchVC.text);
    handleSearchAction();
  }

  ///搜素触发方法
  handleSearchAction() async {
    String searchText = _searchVC.text;
    debugPrint("===$searchText");
    if (StringUtil.isEmpty(searchText)) {
      return;
    }
    if (_originLatLng == null) {
      _originLatLng = await CalculateTools().convertCoordinate(
          lat: widget.timeline.lat,
          lon: widget.timeline.lon,
          type: LatLngType.gps);
    }
    if (isInChina()) {
      poiList = await http.requestPois(
          lat: _originLatLng.latitude,
          lon: _originLatLng.longitude,
          keywords: searchText,
          types: "",
          radius: LocationConfig.poiSearchInterval.toInt());
      print("start1......");
    } else {
      print("start......");
      poiList = await http.requestLocations(
          latlon: "${widget.timeline.lat}, ${widget.timeline.lon}",
          near: searchText);
    }

    if (poiList != null && poiList.length > 0) {
      isSearching = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  getPoi() async {
    print("===0===");
    if (poiPreList != null && poiPreList.length > 0 && !isSearching) {
      poiList = poiPreList;
      setState(() {});
      return;
    }
    if (_originLatLng == null) {
      _originLatLng = await CalculateTools().convertCoordinate(
          lat: widget.timeline.lat,
          lon: widget.timeline.lon,
          type: LatLngType.gps);
    }

    if (isInChina()) {
      poiPreList = await http.requestPois(
          lat: _originLatLng.latitude,
          lon: _originLatLng.longitude,
          radius: LocationConfig.poiSearchInterval);
    } else {
      poiPreList = await http.requestLocations(
          latlon: "${_originLatLng.latitude}, ${_originLatLng.longitude}");
    }
    if (!isSearching) {
      poiList = poiPreList;
      if (mounted) {
        setState(() {});
      }
      isPoiFirstLoad = false;

      ///
      if (poiList != null && poiList.length > 0) {
        if (pickPoi == null) {
          AmapPoi amapPoi = AmapPoi();
          if (StringUtil.isEmpty(widget.timeline.customAddress)) {
            amapPoi.name = widget.timeline.poiName;
            amapPoi.address = widget.timeline.poiAddress;
          } else {
            amapPoi.name = widget.timeline.customAddress;
            amapPoi.address = widget.timeline.poiAddress;
          }
          amapPoi.id = widget.timeline.poiId;
          amapPoi.location = widget.timeline.poiLocation;
          amapPoi.distance = widget.timeline.distance;
          amapPoi.type = widget.timeline.poiType;
          amapPoi.typecode = widget.timeline.poiTypeCode;

          if (amapPoi.id == null) {
            pickPoi = poiList.first;
          } else {
            for (AmapPoi p in poiList) {
              if (p.id == amapPoi.id) {
                pickPoi = p;
                break;
              }
            }
            if (pickPoi == null) {
              pickPoi = amapPoi;
              poiList.insert(0, amapPoi);
            }
          }
        }
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  bool isInChina() {
    return ("中国" == widget.timeline.country) ||
        ("China" == widget.timeline.country);
  }

  bool isShowCheck(String poiId) {
    if (pickPoi != null && StringUtil.isNotEmpty(pickPoi.id)) {
      if (poiId == pickPoi.id) {
        return true;
      } else {
        return false;
      }
    }
    if (widget.timeline.customAddress == poiId) {
      return true;
    }
    return false;
  }

  clickPOI(AmapPoi amapPoi) async {
    pickPoi = amapPoi;
    if (StringUtil.isNotEmpty(amapPoi.location)) {
      List lonlat = amapPoi.location.split(",");
      if (lonlat.length >= 2) {
        double lat = double.tryParse(lonlat[1]);
        double lon = double.tryParse(lonlat[0]);
        _poiLatLng = LatLng(lat, lon);
      }
    }

    await _controller.clearMarkers();
    await _controller.addMarker(MarkerOptions(
      position: _poiLatLng,
    ));
    if (_originLatLng != null) {
      await _controller.addMarker(MarkerOptions(
        position: _originLatLng,
        icon: "assets/images/icon_location.png",
      ));
    }
    _controller.zoomToSpan([_poiLatLng, _originLatLng]);
    _addressTextFieldVC.text = pickPoi?.name;
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

  void _showAlertView(BuildContext cxt) {
    String title = "确认删除地点 ${_addressTextFieldVC.text} ？";
    showCupertinoModalPopup<int>(
        context: cxt,
        builder: (cxt) {
          var dialog = CupertinoActionSheet(
            ///title: Text("This is Title"),
            message: Text(title),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(cxt, 0);
                },
                child: Text("取消")),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    clickDeleteStory();
                    Navigator.pop(cxt, 1);
                  },
                  child: Text(
                    "删除",
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          );
          return dialog;
        });
  }

  ///删除当前story
  clickDeleteStory() async {
    Timeline timeline = widget.timeline;
    if (timeline.uuid != null) {
      await TimelineHelper().deleteTimeline(timeline);
    }
    Navigator.pop(context, true);
  }

  ///保存编辑页面数据
  clickSave() async {
    //TODO:
    bool needRefresh = false;
    if (isSaving) return;

    isSaving = true;

    LoadingDialog loading = LoadingDialog(
      outsideDismiss: false,
      loadingText: "保存中...",
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return loading;
        });
    await Future.delayed(Duration(milliseconds: 500));
    Timeline timeline = widget.timeline;

    ///备注保存
    if (timeline.desc != _descTextFieldVC.text) {
      timeline.desc = _descTextFieldVC.text ?? "";
      await TimelineHelper().updateTimelineDesc(timeline);
      needRefresh = true;
    }

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
    if (_addressFocusNode.hasFocus) {
      isSwitchToEditAddress = false;
      _addressFocusNode.unfocus();
      String str = _addressTextFieldVC.text;
      if (StringUtil.isEmpty(str)) {
        _addressTextFieldVC.text = StringUtil.isNotEmpty(pickPoi?.name)
            ? pickPoi?.name
            : getShowAddress(widget.timeline);
      }
    }

    ///自定义地点保存
    if (pickPoi != null && StringUtil.isNotEmpty(pickPoi.name)) {
      timeline.poiAddress = pickPoi.address;
      timeline.poiLocation = "${pickPoi.location},GCJ02";
      timeline.poiTypeCode = pickPoi.typecode;
      timeline.poiType = pickPoi.type;
      timeline.poiName = pickPoi.name;
      timeline.poiId = pickPoi.id;
      timeline.isConfirm = 1;
      timeline.customAddress = _addressTextFieldVC.text;
      await TimelineHelper().updateEditTimeItemAndSame(timeline);
      needRefresh = true;

      ///存储该pick 点 如果没存过的话
    } else {
      timeline.customAddress = _addressTextFieldVC.text;
      timeline.isConfirm = 1;
      await TimelineHelper().updateEditTimeItemAndSame(timeline);
      needRefresh = true;
    }

    ///进度消失
    await loading.handleDismiss();

    ///返回
    Navigator.pop(context, needRefresh);
    isSaving = false;
  }

  getShowAddress(Timeline timeline) {
    if (StringUtil.isNotEmpty(widget.timeline.customAddress)) {
      return widget.timeline.customAddress;
    }
    return timeline.poiName;
  }
}
