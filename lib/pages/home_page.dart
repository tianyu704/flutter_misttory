import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_amap_location_plugin/amap_location_lib.dart' as amap;
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/location_db_helper.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/db/helper/timeline_helper.dart';
import 'package:misstory/db/local_storage.dart';
import 'package:misstory/eventbus/event_bus_util.dart';
import 'package:misstory/eventbus/refresh_progress.dart';
import 'package:misstory/location_config.dart';
import 'package:misstory/models/coord_type.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/models/timeline.dart';
import 'package:misstory/pages/pictures_page.dart';
import 'package:misstory/pages/pois_page.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/utils/channel_util.dart';
import 'package:misstory/utils/date_util.dart';
import 'package:misstory/utils/location_channel.dart';
import 'package:misstory/utils/print_util.dart';
import 'package:misstory/widgets/loading_pictures_alert.dart';
import 'package:misstory/widgets/location_item.dart';
import 'package:misstory/widgets/refresh_grouped_listview.dart';
import 'package:misstory/widgets/scroll_top_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:misstory/net/http_manager.dart' as http;
import '../constant.dart';
import 'detail_page.dart';
import 'edit_page.dart';
import 'log_page.dart';
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
  List<Timeline> _timelines = List<Timeline>();
  List<Timeline> _timelineAll = List<Timeline>();
  amap.AMapLocation _aMapLocation;
  StreamSubscription _subscription;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController _scrollController = ScrollController();
  int _day = 0, _footprint = 0;
  Timer _timer;
  bool _isFirstLoad = true;
  bool _isDealWithLocation = false;
  Timeline _currentTimeline;
  StreamSubscription _refreshSubscription;
  bool hasBuild = false;
  LoadingPicturesAlert loadingAlert;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkPermission();
    _startTimerRefresh();
    _refreshSubscription =
        EventBusUtil.listen<RefreshProgress>((refreshProgress) async {
      _day = await TimelineHelper().getStoryDays();
      _footprint = await TimelineHelper().getFootprint();
      _refreshController.loadComplete();
      if (mounted && hasBuild) {
        setState(() {});
      }
      if (_isFirstLoad &&
          (refreshProgress.finish() || refreshProgress.count > 50)) {
        _refreshStory();
      }
      if (loadingAlert != null) {
        loadingAlert.updateProgress(refreshProgress.progress());
        if (refreshProgress.count > 50) {
          loadingAlert.enableClick(true);
        }
        if (refreshProgress.finish()) {
          loadingAlert.dismiss();
          LocalStorage.saveBool(LocalStorage.isStep, true);
        }
      }
    });
  }

  ///同步图片逻辑
  _syncPictures() async {
    bool isStep = await LocalStorage.get(LocalStorage.isStep) ?? false;
    if (!isStep) {
      _showLoadingAlertView(context);
    }
    await PictureHelper().checkSystemPicture();
    if (!PictureHelper().isPictureConverting) {
      await PictureHelper().checkUnSyncedPicture();
    }
  }

  /// 开始每隔1分钟刷新逻辑
  _startTimerRefresh() {
    Future.delayed(Duration(seconds: 60 - DateTime.now().second), () {
      _timer = Timer.periodic(Duration(seconds: LocationConfig.refreshTime),
          (timer) {
        _refreshStory();
      });
    });
  }

  ///刷新最新的story
  _refreshStory() async {
    await LocationHelper().saveLocation();
//    await LocationHelper().createStoryByLocation();
    _currentTimeline = await TimelineHelper().getCurrentStory();
    if (_isFirstLoad) {
      ///初次加载需要查询前20条数据
      _timelines = await TimelineHelper().queryMoreHistories();
      if (_timelines != null && _timelines.length > 0) {
        _isFirstLoad = false;
      }
    } else {
      /// 刷新时获取最新的story
      _timelines = await TimelineHelper().checkLatestStory(_timelines);
    }
    await _mergeStories();
    _day = await TimelineHelper().getStoryDays();
    _footprint = await TimelineHelper().getFootprint();
    if (mounted) {
      setState(() {});
    }
  }

  /// 合并_currentStory和_stories
  _mergeStories() async {
    List<Timeline> temp = [];
    if (_currentTimeline != null) {
      if (_timelines != null && _timelines.length > 0) {
        if (_currentTimeline.uuid != _timelines[0].uuid) {
          temp.add(_currentTimeline);
        } else {
          _timelines[0] = _currentTimeline;
        }
        temp.addAll(_timelines);
      } else {
        temp.add(_currentTimeline);
      }
    } else {
      if (_timelines != null && _timelines.length > 0) {
        temp.addAll(_timelines);
      }
    }
    _timelineAll = temp;
  }

  bool _isLoading = false;

  ///加载更多
  _loadMore() async {
    if (_isLoading) {
      return;
    }
    if (!_isLoading) {
      _isLoading = true;
      num time;
      if (_timelines != null && _timelines.length > 0) {
        time = _timelines[_timelines.length - 1].endTime;
      }
      List<Timeline> list = await TimelineHelper().queryMoreHistories(time: time);
      if (list != null && list.length > 0) {
        _timelines.addAll(list);
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
      if (mounted) {
        _mergeStories();
        setState(() {});
      }
      _isLoading = false;
    }
  }

  /// 检查权限
  void _checkPermission() async {
    PrintUtil.debugPrint("=========start");
    bool pass1 = await ChannelUtil().requestStoragePermission();
    PrintUtil.debugPrint("=========$pass1");
    bool pass2 = await ChannelUtil().requestLocationPermission();
    PrintUtil.debugPrint("=========$pass2");
    if (pass1) {
      _syncPictures();
    }
    if (pass2) {
      _initLocation();
    } else {
      ///TODO 提示开启定位权限
    }
  }

  ///初始化并开始定位
  void _initLocation() async {
    print("===================_initLocation");
    _aMapLocation = amap.AMapLocation();
    await _aMapLocation.init(Constant.androidMapKey, Constant.iosMapKey);
    _subscription = _aMapLocation.onLocationChanged.listen((location) async {
//      print("==========$location");
      if (_isDealWithLocation) {
        return;
      }
      _isDealWithLocation = true;
      if (location != null && location.isNotEmpty) {
        try {
          Mslocation mslocation = Mslocation.fromJson(json.decode(location));
          if (CoordType.aMap != mslocation.coordType) {
            mslocation = await http.requestLocation(mslocation);
          }
          if (mslocation != null && mslocation.errorCode == 0) {
            mslocation.updatetime = mslocation.time;
            debugPrint(
                "===========接收到新定位：${mslocation.lon},${mslocation.lat},${mslocation.time}");
            await LocationHelper().saveLocation();
            int result =
                await LocationHelper().createOrUpdateLocation(mslocation);
            debugPrint("===============$result");
            if (result != -1) {
              await _refreshStory();
            }
          } else {
            if (_isFirstLoad) {
              await _refreshStory();
            }
          }
        } catch (e) {
          print(e.toString());
        }
      }
      _isDealWithLocation = false;
      debugPrint("===========处理新定位完毕！");
    });
    amap.LocationClientOptions options = amap.LocationClientOptions(
      locationMode: amap.LocationMode.Battery_Saving,
      interval: LocationConfig.interval,
      distanceFilter: LocationConfig.distanceFilter,
      isOnceLocation: true,
    );
    _aMapLocation?.start(options);

    LocationChannel().start(
        interval: LocationConfig.interval,
        distanceFilter: LocationConfig.distanceFilter);
    LocationChannel().onLocationChanged.listen((location) {
      PrintUtil.debugPrint("获取到原生定位信息-----${location.toJson()}");
      LocationDBHelper().saveNewLocation(location);
    });
    LocationChannel().getCurrentLocation().then((location) {
      PrintUtil.debugPrint("获取一次原生定位信息-----${location.toJson()}");
      LocationDBHelper().saveNewLocation(location);
    });
  }

  ///请求一次定位
  void _onceLocate() async {
    amap.LocationClientOptions options = amap.LocationClientOptions(
      locationMode: amap.LocationMode.Battery_Saving,
      interval: LocationConfig.interval,
      distanceFilter: LocationConfig.distanceFilter,
      isOnceLocation: true,
    );
    await _aMapLocation?.start(options);
  }

  @override
  Widget build(BuildContext context) {
    hasBuild = true;
    // TODO: implement build
    return Scaffold(
      backgroundColor: AppStyle.colors(context).colorBgPage,
      appBar: AppBar(
        centerTitle: false,
        title: _buildHeader(),
        actions: <Widget>[
          Offstage(
            offstage: !Constant.isDebug,
            child: FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return SearchPage("");
                  }));
                },
                child: Text("Debug")),
          ),
          Offstage(
            offstage: false,
            child: FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return LogPage();
                  }));
                },
                child: Text("settings")),
          ),
        ],
        backgroundColor: AppStyle.colors(context).colorBgPage,
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          _storyListWidget(context),
          ScrollTopButton(20, 20, _scrollController),
        ],
      ),
    );
  }

  ///分组设置卡片布局
  Widget _storyListWidget(BuildContext context) {
    return RefreshGroupedListView<Timeline, String>(
      _refreshController,
      collection: _timelineAll,
      groupBy: (Timeline g) => g.date,
      listBuilder: (BuildContext context, TItem<Timeline> item) =>
          _buildCardItem(context, item),
      groupBuilder: (BuildContext context, String name) =>
          _groupSectionWidget(context, name),
      onLoading: _loadMore,
      scrollController: _scrollController,
    );
  }

  /// 头部导航栏
  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text: " ${_day == 0 ? "-" : _day}",
                style: AppStyle.primaryText28(context)),
            TextSpan(text: " 天 ", style: AppStyle.contentText16(context)),
            TextSpan(
                text: "${_footprint == 0 ? "-" : _footprint}",
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
  Widget _buildCardItem(context, TItem<Timeline> item) {
    return LocationItem(
      item,
      onPressCard: () {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => EditPage(item.tElement)))
            .then(_notifyStories);
      },
      onPressPicture: () {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => PicturesPage(item.tElement)))
            .then(_notifyStories);
      },
      onTapMore: () {
//        if (item.tElement.others != null && item.tElement.others.length > 0) {
//          Navigator.of(context)
//              .push(MaterialPageRoute(
//                  builder: (context) => DetailPage(item.tElement.others)))
//              .then(_notifyStories);
//        }
      },
    );
  }

  ///分组的UI卡片
  Widget _groupSectionWidget(BuildContext context, String groupName) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.only(left: 24, top: 20, bottom: 10, right: 24),
        child: Text(
          DateUtil.getMonthDayWeek(context, groupName),
          style: AppStyle.mainText18(context, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  void onResume() {
    // TODO: implement onResume
    super.onResume();
    if (!_isFirstLoad) {
      if (Platform.isAndroid) {
        _onceLocate();
      }
      refreshNewPictures().then((_) {
        _refreshStory();
      });
    }
  }

  Future refreshNewPictures() async {
    await PictureHelper().checkSystemPicture();
    await PictureHelper().checkPicture();
    if (!PictureHelper().isPictureConverting) {
      await PictureHelper().checkUnSyncedPicture();
    }
  }

  _notifyStories(value) async {
    if (value != null && value is bool && value) {
      if (_timelines != null && _timelines.length > 0) {
        _timelines = await TimelineHelper()
            .findAfterStories(_timelines[_timelines.length - 1].startTime);
        if (mounted) {
          _refreshStory();
        }
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _subscription.cancel();
    _refreshSubscription.cancel();
    _aMapLocation.dispose();
    _refreshController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _showLoadingAlertView(BuildContext cxt) {
    loadingAlert = LoadingPicturesAlert(
      alertTitle: richTitle("初次使用需根据您的相册\n为您生成时间轴", context),
      alertSubtitle: richSubtitle("此过程大概需要3～5分钟", context),
      cancelProgressBlock: () {
        LocalStorage.saveBool(LocalStorage.isStep, true);
      },
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return loadingAlert;
        });
  }

  @override
  void onForeground() {
    // TODO: implement onForeground
    super.onForeground();
  }
}
