import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
import '../constant.dart';
import 'edit_page.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();
    initData();
  }

  /// 检查权限
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
    await _aMapLocation.init(Constant.androidMapKey, Constant.iosMapKey);
    _subscription = _aMapLocation.onLocationChanged.listen((location) async {
      if (location != null && location.isNotEmpty) {
        try {
          Mslocation mslocation = Mslocation.fromJson(json.decode(location));
          if (mslocation != null) {
            mslocation.updatetime = mslocation.time;
            debugPrint("===========接收到新定位：${mslocation.lon},${mslocation.lat}");
            int result =
                await LocationHelper().createOrUpdateLocation(mslocation);
//            debugPrint("===============$result");
            if (result != -1) {
              initData();
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
      body: storyListWidget(context),
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
              Expanded(flex: 1, child: Text(getShowAddress(story))),
              Text(DateUtil.getStayShowTime(story.intervalTime)),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.mode_edit, size: 17),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => EditPage(story)));
        },
      ),
    );
  }

  ///显示的地址
  getShowAddress(Story story) {
    if (StringUtil.isEmpty(story.aoiName)) {
      return StringUtil.isEmpty(story.poiName) ? story.address : story.poiName;
    }
    return story.aoiName;
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
  Widget storyListWidget(BuildContext context) {
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
    super.dispose();
  }
}
