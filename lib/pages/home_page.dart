import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_amap_location_plugin/amap_location_lib.dart' as amap;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:intl/intl.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/eventbus/event_bus_util.dart';
import 'package:misstory/eventbus/refresh_day.dart';
import 'package:misstory/eventbus/refresh_home.dart';
import 'package:misstory/location_config.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/pages/pictures_page.dart';
import 'package:misstory/pages/pois_page.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/utils/date_util.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/widgets/location_item.dart';
import 'package:misstory/widgets/refresh_grouped_listview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
  List<Story> _storiesAll = List<Story>();
  amap.AMapLocation _aMapLocation;
  StreamSubscription _subscription;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _day = 0, _footprint = 0;
  Timer _timer;
  bool _isInitState = false;
  bool _isDealWithLocation = false;
  Story _currentStory;
  StreamSubscription _refreshSubscription;
  StreamSubscription _refreshHomeSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("=============initstate");
//    _syncPictures();
    _checkPermission();
    _refreshStory(true);
    _startTimerRefresh();
    _isInitState = true;

    _refreshSubscription = EventBusUtil.listen<RefreshDay>((refreshDay) async {
      _day = await StoryHelper().getStoryDays();
      _footprint = await StoryHelper().getFootprint(_storiesAll);
      _refreshController.loadComplete();
      setState(() {});
    });

    _refreshHomeSubscription =
        EventBusUtil.listen<RefreshHome>((refreshHome) async {
      _refreshStory(false);
    });
  }

  ///同步图片逻辑
  _syncPictures() async {
    await PictureHelper().convertPicturesToLocations();
    if (mounted) {
      _refreshStory(false);
    }
  }

  /// 开始每隔1分钟刷新逻辑
  _startTimerRefresh() {
    Future.delayed(Duration(seconds: 60 - DateTime.now().second), () {
      _timer = Timer.periodic(Duration(seconds: LocationConfig.refreshTime),
          (timer) {
        _refreshStory(false);
      });
    });
  }

  ///刷新最新的story
  _refreshStory(bool first) async {
    await LocationHelper().saveLocation();
    await LocationHelper().createStoryByLocation();
    _currentStory = await StoryHelper().getCurrentStory();
    if (first) {
      ///初次加载需要查询前20条数据
      _stories = await StoryHelper().queryMoreHistories();
    } else {
      /// 刷新时获取最新的story
      _stories = await StoryHelper().checkLatestStory(_stories);
    }
    await _mergeStories();
    _day = await StoryHelper().getStoryDays();
    _footprint = await StoryHelper().getFootprint(_storiesAll);
    if (mounted) {
      setState(() {});
    }
  }

  /// 合并_currentStory和_stories
  _mergeStories() async {
    List<Story> temp = [];
    if (_currentStory != null) {
      if (_stories != null && _stories.length > 0) {
        if (await StoryHelper().judgeSamePlace(_currentStory, _stories[0])) {
          _stories[0].updateTime = DateTime.now().millisecondsSinceEpoch;
          _stories[0].intervalTime =
              _stories[0].updateTime - _stories[0].createTime;
          _stories[0].pictures = _currentStory.pictures;
          temp.addAll(_stories);
        } else {
          temp.add(_currentStory);
          temp.addAll(_stories);
        }
        Story story = temp.removeAt(0);
        temp.insertAll(0, await StoryHelper().separateStory(story));
      } else {
        temp.add(_currentStory);
      }
    } else {
      if (_stories != null && _stories.length > 0) {
        temp.addAll(_stories);
      }
    }
    _storiesAll = temp;
  }

  bool _isLoading = false;

  ///加载更多
  _loadMore() async {
    if (_isLoading) {
      return;
    }
    if (!_isLoading && _stories != null && _stories.length > 0) {
      _isLoading = true;
      List<Story> list = await StoryHelper()
          .queryMoreHistories(time: _stories[_stories.length - 1].updateTime);
      if (list != null && list.length > 0) {
        _stories.addAll(list);
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
    await PermissionHandler().requestPermissions(
        [PermissionGroup.locationAlways, PermissionGroup.storage]);
    PermissionStatus permissionLocation = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationAlways);
    PermissionStatus permissionStorage = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (Platform.isAndroid &&
        permissionLocation == PermissionStatus.granted &&
        permissionStorage == PermissionStatus.granted) {
      _initLocation();
    } else if (Platform.isIOS &&
        permissionLocation == PermissionStatus.granted) {
      _initLocation();
    }
  }

  ///初始化并开始定位
  void _initLocation() async {
    print("===================_initLocation");
    _aMapLocation = amap.AMapLocation();
    await _aMapLocation.init(Constant.androidMapKey, Constant.iosMapKey);
    _subscription = _aMapLocation.onLocationChanged.listen((location) async {
      if (_isDealWithLocation) {
        return;
      }
      _isDealWithLocation = true;
      if (location != null && location.isNotEmpty) {
        try {
          Mslocation mslocation = Mslocation.fromJson(json.decode(location));
          if (mslocation != null) {
            mslocation.updatetime = mslocation.time;
            debugPrint(
                "===========接收到新定位：${mslocation.lon},${mslocation.lat},${mslocation.time}");
            await LocationHelper().saveLocation();
            int result =
                await LocationHelper().createOrUpdateLocation(mslocation);
            debugPrint("===============$result");
            if (result != -1) {
              await _refreshStory(false);
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
    await _aMapLocation?.start(options);
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
        ],
        backgroundColor: AppStyle.colors(context).colorBgPage,
        elevation: 0,
      ),
      body: _storyListWidget(context),
    );
  }

  ///分组设置卡片布局
  Widget _storyListWidget(BuildContext context) {
    return RefreshGroupedListView<Story, String>(
      _refreshController,
      collection: _storiesAll,
      groupBy: (Story g) => g.date,
      listBuilder: (BuildContext context, TItem<Story> item) =>
          _buildCardItem(context, item),
      groupBuilder: (BuildContext context, String name) =>
          _groupSectionWidget(context, name),
      onLoading: _loadMore,
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
                text: " ${_day == 0 ? "1" : _day}",
                style: AppStyle.primaryText28(context)),
            TextSpan(text: " 天 ", style: AppStyle.contentText16(context)),
            TextSpan(
                text: "${_footprint == 0 ? "0" : _footprint}",
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
  Widget _buildCardItem(context, TItem<Story> item) {
    return LocationItem(
      item,
      onPressCard: () {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => EditPage(item.tElement)))
            .then(
          (value) {
            if (value != null) {
              Map<num, Story> stories = value[0];
              if (stories != null && stories.length > 0) {
                notifyStories(stories);
              }
            }
          },
        );
      },
      onPressPicture: () {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => PicturesPage(item.tElement)))
            .then(
          (value) {
            if (value != null) {
              Map<num, Story> stories = value[0];
              if (stories != null && stories.length > 0) {
                notifyStories(stories);
              }
            }
          },
        );
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
    if (_isInitState) {
      if (Platform.isAndroid) {
        print("]]]]]]]]]]]]]]]]]]]]]]");
        _onceLocate();
      }
      refreshNewPictures().then((_) {
        _refreshStory(false);
      });
    }
  }

  Future refreshNewPictures() async {
    if (_storiesAll != null && _storiesAll.length > 0) {
      await PictureHelper().fetchAppSystemPicture();
      await PictureHelper().convertPicturesAfterTime(_storiesAll[0].createTime);
    }
  }

  ///从编辑页面返回后的刷新
  notifyStories(Map<num, Story> stories) {
    if (_storiesAll != null && _storiesAll.length > 0) {
      _storiesAll.forEach((item) {
        if (stories.containsKey(item.id)) {
          item.lat = stories[item.id].lat;
          item.lon = stories[item.id].lon;
          item.customAddress = stories[item.id].customAddress;
          item.desc = stories[item.id].desc;
        }
      });
      setState(() {});
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _subscription.cancel();
    _refreshSubscription.cancel();
    _refreshHomeSubscription.cancel();
    _aMapLocation.dispose();
    _refreshController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
