import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_location_plugin/amap_location_lib.dart' as amap;
import 'package:grouped_listview/grouped_listview.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:intl/intl.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/location_config.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/utils/date_util.dart';
import 'package:misstory/utils/string_util.dart';
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
//      print(location);
      if (location != null && location.isNotEmpty) {
        try {
          Mslocation mslocation = Mslocation.fromJson(json.decode(location));
          if (mslocation != null) {
            mslocation.updatetime = mslocation.time;
            int result =
                await LocationHelper().createOrUpdateLocation(mslocation);
//            debugPrint("===============$result");
            if (result != -1) {
//              await StoryHelper().judgeLocation(mslocation);
              initData();
              _currentLatLng = LatLng(mslocation.lat, mslocation.lon);
              _controller.changeLatLng(_currentLatLng);
              _controller.addMarker(MarkerOptions(
                position: _currentLatLng,
              ));
            }
          }
        } catch (e) {
          print(e.toString());
        }
      }
    });
    amap.LocationClientOptions options = amap.LocationClientOptions(
      locationMode: amap.LocationMode.Battery_Saving,
      interval: LocationConfig.interval,
      distanceFilter: LocationConfig.distanceFilter,
      isOnceLocation: true,
    );
    await _aMapLocation.start(options);
  }

  initData() async {
    await LocationHelper().createStoryByLocation();
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
            child: groupWidget(context),
          ),
        ],
      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
//            return PoisPage(_poisString);
//          }));
//        },
//      ),
    );
  }

  ///展示定位的卡片
  Widget _buildCardItem(context, Story story) {
    String date = "";
    if (story?.createTime != null && story.createTime != 0) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(story.createTime.toInt());
      date = DateFormat("HH:mm").format(dateTime);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("$date "),
              Icon(Icons.location_on, size: 17),
              Expanded(
                  flex: 1,
                  child: Text(StringUtil.isEmpty(story.aoiName)
                      ? story.poiName
                      : story.aoiName)),
              Text(DateUtil.getStayShowTime(story.intervalTime)),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.mode_edit, size: 17),
              ),
            ],
          ),
        ),
        onTap: () {
          //TODO:
        },
      ),
    );
  }

  ///分组的UI卡片
  Widget groupSectionWidget(BuildContext context, String groupName) {
    return SizedBox(
        child: Padding(
      padding: EdgeInsets.all(10),
      child:
          Text("•   $groupName", style: TextStyle(fontWeight: FontWeight.bold)),
    ));
  }

  ///分组设置卡片布局
  Widget groupWidget(BuildContext context) {
    return GroupedListView<Story, String>(
      collection: _stories,
      groupBy: (Story g) => g.date,
      listBuilder: (BuildContext context, Story g) =>
          _buildCardItem(context, g),
      groupBuilder: (BuildContext context, String name) =>
          groupSectionWidget(context, name),
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

class Group {}
