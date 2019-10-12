import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_location_plugin/amap_location_lib.dart' as amap;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:full_icon_button/full_icon_text.dart';
import 'package:grouped_listview/grouped_listview.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:intl/intl.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/location_config.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/style/app_style.dart';
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
  int _day = 0, _footprint = 0;
  Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPermission();
    initData();
    _startTimerRefresh();
  }

  /// 开始每隔1分钟刷新逻辑
  _startTimerRefresh() {
    Future.delayed(Duration(seconds: 60 - DateTime.now().second), () {
      _timer = Timer.periodic(Duration(seconds: LocationConfig.refreshTime),
          (timer) async {
        _stories = await StoryHelper().checkLatestStory(_stories);
        setState(() {});
      });
    });
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
    _day = await StoryHelper().getStoryDays();
    _footprint = await StoryHelper().getFootprint();
    _stories = await StoryHelper().findAllStories();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: AppStyle.colors(context).colorBgPage,
      appBar: AppBar(
        centerTitle: false,
        title: _buildHeader(),
        backgroundColor: AppStyle.colors(context).colorBgPage,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
//          _buildHeader(),
          Expanded(
            flex: 1,
            child: _storyListWidget(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text: " ${_day == 0 ? "--" : _day}",
                style: AppStyle.primaryText28(context)),
            TextSpan(text: " 天 ", style: AppStyle.contentText16(context)),
            TextSpan(
                text: "${_footprint == 0 ? "--" : _footprint}",
                style: AppStyle.primaryText28(context)),
            TextSpan(text: " 个足迹", style: AppStyle.contentText16(context)),
          ],
        ),
        style: TextStyle(fontWeight: FontWeight.normal),
        textAlign: TextAlign.start,
      ),
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
      margin: EdgeInsets.only(left: 40, top: 8, bottom: 8, right: 16),
      color: AppStyle.colors(context).colorBgCard,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 0,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 56,
                child: Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text(
                    "$date",
                    style: AppStyle.locationText14(context),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SvgPicture.asset(
                          StringUtil.isEmpty(story.customAddress)
                              ? "assets/images/icon_location_empty.svg"
                              : "assets/images/icon_location_fill.svg",
                          width: 14,
                          height: 14,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            StringUtil.isEmpty(story.customAddress)
                                ? story.defaultAddress
                                : story.customAddress,
                            style: AppStyle.locationText14(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        SvgPicture.asset(
                          "assets/images/icon_remain_time.svg",
                          width: 12,
                          height: 12,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 11),
                          child: Text(
                            DateUtil.getStayShowTime(story.intervalTime),
                            style: AppStyle.descText12(context),
                          ),
                        ),
                      ],
                    ),
                    Offstage(
                      offstage: StringUtil.isEmpty(story.desc),
                      child: Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          story?.desc ?? "",
                          style: AppStyle.contentText12(context),
                        ),
                      ),
                    ),
                  ],
                ),
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

  ///分组的UI卡片
  Widget _groupSectionWidget(BuildContext context, String groupName) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.only(left: 24, top: 8, bottom: 8),
        child: Text(
          DateUtil.getMonthDayWeek(context, groupName),
          style: AppStyle.mainText16(context, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  ///分组设置卡片布局
  Widget _storyListWidget(BuildContext context) {
    return GroupedListView<Story, String>(
      collection: _stories,
      groupBy: (Story g) => g.date,
      listBuilder: (BuildContext context, Story g) =>
          _buildCardItem(context, g),
      groupBuilder: (BuildContext context, String name) =>
          _groupSectionWidget(context, name),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _subscription.cancel();
    _aMapLocation.dispose();
    _timer.cancel();
    super.dispose();
  }
}
