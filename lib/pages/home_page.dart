import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_location_plugin/amap_location_lib.dart' as amap;
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:intl/intl.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/pages/pois_page.dart';
import 'package:permission_handler/permission_handler.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-09-26
///
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePageState();
  }
}

class _HomePageState extends LifecycleState<HomePage> {
  List<Story> _stories = List<Story>();
  amap.AMapLocation _aMapLocation;
  StreamSubscription _subscription;
  String time = DateFormat("MM-dd HH:mm").format(DateTime.now());
  AMapController _controller;
  StreamSubscription _subscriptionMap;
  LatLng _currentLatLng;
  MyLocationStyle _myLocationStyle;
  AMapSearch _aMapSearch;
  String _poisString = "暂无poi信息";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();
    initData();
  }

  void checkPermission() async {
    await PermissionHandler().requestPermissions(
        [PermissionGroup.locationAlways, PermissionGroup.storage]);
    PermissionStatus permissionLocation = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationAlways);
    PermissionStatus permissionStorage = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (Platform.isAndroid &&
        permissionLocation == PermissionStatus.granted &&
        permissionStorage == PermissionStatus.granted) {
      initLocation();
    } else if (Platform.isIOS &&
        permissionLocation == PermissionStatus.granted) {
      initLocation();
    }
  }

  void initLocation() async {
    _aMapLocation = amap.AMapLocation();
    _aMapSearch = AMapSearch();
    await _aMapLocation.init(
        "77419f4f5b07ffcc0a41cafd2fe763af", "11bcf7a88c8b1a9befeefbaa2ceaef71");
    _subscription = _aMapLocation.onLocationChanged.listen((location) async {
      location = location.replaceAll("true", "1");
      location = location.replaceAll("false", "0");
//      print(location);
      if (location != null && location.isNotEmpty) {
        try {
          Mslocation mslocation = Mslocation.fromJson(json.decode(location));
          if (mslocation != null) {
            int result = await LocationHelper().createLocation(mslocation);
            if (result != -1) {
              await StoryHelper().judgeLocation(mslocation);
              initData();
              _currentLatLng = LatLng(mslocation.lat, mslocation.lon);
              _controller.changeLatLng(_currentLatLng);
              _controller.addMarker(MarkerOptions(
                position: _currentLatLng,
              ));
//              _aMapSearch
//                  .searchPoi(PoiSearchQuery(
//                      query: mslocation.poiname,
////                      location: _currentLatLng,
//                      city: mslocation.citycode,
//                      searchBound:
//                          SearchBound(range: 1000, center: _currentLatLng)))
//                  .then((result) {
//                _poisString = result.toJson().toString();
//                print("=============$_poisString");
//              }, onError: () {
//                print("=============ERROR");
//              });
            }
          }
        } catch (e) {
          print(e.toString());
        }
      }
    });
    amap.LocationClientOptions options = amap.LocationClientOptions(
      locationMode: amap.LocationMode.Battery_Saving,
      interval: 60 * 1000 * 5,
      distanceFilter: 1000,
    );
    await _aMapLocation.start(options);
  }

  initData() async {
    _stories = await StoryHelper().findAllStories();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("今天,open:$time"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 250,
            width: double.infinity,
            child: AMapView(
              onAMapViewCreated: (controller) {
                _controller = controller;
//                _subscriptionMap = _controller.mapClickedEvent
//                    .listen((it) => print('地图点击: 坐标: $it'));
                _myLocationStyle = MyLocationStyle(
                  strokeColor: Color(0x662196F3),
                  radiusFillColor: Color(0x662196F3),
                  showMyLocation: true,
                );
                _controller.setUiSettings(UiSettings(
                  isMyLocationButtonEnabled: true,
                  logoPosition: LOGO_POSITION_BOTTOM_LEFT,
                  isZoomControlsEnabled: false,
                ));
                _controller.setMyLocationStyle(_myLocationStyle);
                _controller.setZoomLevel(16);
              },
//              amapOptions: AMapOptions(
//                compassEnabled: false,
//                zoomControlsEnabled: true,
//                logoPosition: LOGO_POSITION_BOTTOM_CENTER,
//                camera: CameraPosition(
//                  target: LatLng(39.900234, 116.492712),
//                  zoom: 10,
//                ),
//              ),
            ),
          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return PoisPage(_poisString);
          }));
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
    Story story = _stories[index];
    String date = "";
    if (story?.createTime != null && story.createTime != 0) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(story.createTime.toInt());
      date = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
    }
    String upate = "";
    if (story?.updateTime != null && story.updateTime != 0) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(story.updateTime.toInt());
      upate = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("aoi:${story.aoiName}"),
            Text("poi:${story.poiName}"),
            Text("地址：${story.address}"),
            Text("经纬度:(${story.lon},${story.lat})"),
            Text("日期:$date"),
            Text("更新日期:$upate"),
            Text("停留时间:${(story.intervalTime / 1000 / 60).toInt()}分"),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _subscription.cancel();
    _aMapLocation.dispose();
    _controller.dispose();
    super.dispose();
  }
}
