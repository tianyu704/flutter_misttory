import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/db/local_storage.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/net/http_manager.dart' as http;
import 'package:misstory/utils/calculate_util.dart';
import 'package:misstory/utils/channel_util.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-09-27
///
class SearchPage extends StatefulWidget {
  final String json;

  SearchPage(this.json);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchPageState();
  }
}

class _SearchPageState extends LifecycleState<SearchPage> {
  TextEditingController _controller;
  ScrollController _scrollController = ScrollController();
  AMapSearch _aMapSearch = AMapSearch();
  List<LocalImage> images;
  String _result = "adfasfas";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
  }

  requestPermission() async {
    print("=========start");
    bool allow1 = await ChannelUtil().requestLocationPermission();
    if (allow1) {
      print("=========granted1");
    } else {
      print("=========denied1");
    }
    bool allow2 = await ChannelUtil().requestStoragePermission();
    if (allow2) {
      print("=========granted2");
    } else {
      print("=========denied2");
    }
//    await PermissionHandler().requestPermissions(
//        [PermissionGroup.storage, PermissionGroup.locationAlways]);
    print("=========pass1");
//    await PermissionHandler()
//        .requestPermissions([PermissionGroup.locationAlways]);
//    print("=========pass2");
//    PermissionStatus permissionLocation = await PermissionHandler()
//        .checkPermissionStatus(PermissionGroup.locationAlways);
//    PermissionStatus permissionStorage = await PermissionHandler()
//        .checkPermissionStatus(PermissionGroup.storage);
//    print("=========$permissionLocation,$permissionStorage");
//    if (Platform.isAndroid &&
//        permissionLocation == PermissionStatus.granted &&
//        permissionStorage == PermissionStatus.granted) {
//      _syncPictures();
//    } else if (Platform.isIOS &&
//        permissionLocation == PermissionStatus.granted) {
//      _syncPictures();
//    }
  }

  @override
  Widget build(BuildContext context) {
    _getPicture();
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Pois"),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          //AppBar，包含一个导航栏
          SliverAppBar(
            pinned: true,
            elevation: 0,
            floating: true,
            bottom: PreferredSize(
              child: Container(
                color: Colors.red,
                height: 100,
                child: Row(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () async {
//                    if (images != null && images.length > 0) {
//                      LatLng latlng = await CalculateTools().convertCoordinate(
//                          lat: images[0].lat,
//                          lon: images[0].lon,
//                          type: LatLngType.gps);
//                      print(latlng.toJson());
                        //39°53'56.118",116°29'11.964"
                        //39.898923,116.48666
                        //40.74224,-73.99386
                        //37.5536,126.921774
                        //28.189403,113.212998
                        _aMapSearch
                            .searchReGeocode(
                                LatLng(28.189403, 113.212998), 100, 1)
                            .then((result) {
                          _result = result.regeocodeAddress.toString();
                          debugPrint(result.toString());
                          setState(() {});
                        });
//                    }
                      },
                      child: Text("高德获取"),
                    ),
                    RaisedButton(
                      onPressed: () async {
//                    if (images != null && images.length > 0) {
//                      LatLng latlng = await CalculateTools().convertCoordinate(
//                          lat: images[0].lat,
//                          lon: images[0].lon,
//                          type: LatLngType.gps);
//                      print(latlng.toJson());
                        //39°53'56.118",116°29'11.964"
                        //39.898923,116.48666
                        //40.74224,-73.99386
                        //37.5536,126.921774
                        //28.189403,113.212998
                        Mslocation mslocation = Mslocation()
                          ..lat = 28.189403
                          ..lon = 113.212998
                          ..errorCode = 0;
//                        mslocation = await http.requestLocation(mslocation);
//                        _result = mslocation?.toJson()?.toString() ?? "空";
//                        debugPrint(_result);
//                        setState(() {});
//                    }
                      },
                      child: Text("foursquare获取"),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        LatLng latLng1 = LatLng(39.898923, 116.48666);
                        LatLng latLng2 = LatLng(39.898923, 116.48566);
                        num a = await CalculateTools()
                            .calcDistance(latLng1, latLng2);
                        print(a);
                      },
                      child: Text("计算距离"),
                    )
                  ],
                ),
              ),
              preferredSize: Size(double.infinity, 100),
            ),
            centerTitle: true,
            expandedHeight: 250,
            leading: Text(""),
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    maxLines: 5,
                    scrollPhysics: BouncingScrollPhysics(),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Text(_result),
          ),
          //List
//          new SliverFixedExtentList(
//            itemExtent: 50.0,
//            delegate: new SliverChildBuilderDelegate(
//              (BuildContext context, int index) {
//                //创建列表项
//                return new Container(
//                  alignment: Alignment.center,
//                  color: Colors.lightBlue[100 * (index % 9)],
//                  child: new Text('list item $index'),
//                );
//              },
//              childCount: 50, //50个列表项
//            ),
//          ),
          SliverToBoxAdapter(
            child: RaisedButton(
                child: Text("测试存储Picture"),
                onPressed: () {
                  _syncPictures();
                }),
          ),
          SliverToBoxAdapter(
            child: RaisedButton(
                child: Text("删除Picture和Picture生成的Location、Story"),
                onPressed: () async {
                  await PictureHelper().clear();
                  await LocationHelper().deletePictureLocation();
                  await StoryHelper().deletePictureStory();
                  await LocalStorage.saveBool(LocalStorage.isStep, false);
                  await LocalStorage.saveInt(LocalStorage.dbVersion, 0);
                  debugPrint("！！！！！！！！！删除成功！！！！！！！");
//                    debugPrint("=========${await StoryHelper().getDistanceBetween1()}");
                }),
          ),
          SliverToBoxAdapter(
            child: RaisedButton(
                child: Text("wgs84转gcj02"),
                onPressed: () async {
                  //39.89881441318218,116.48662651612794
                  var a = await CalculateUtil.wgsToGcj(
                      39.89881441318218,
                      116.48662651612794);
                  debugPrint("!!!!!!!!!!!!!${a.toJson()}");
//                    debugPrint("=========${await StoryHelper().getDistanceBetween1()}");
                }),
          ),
          SizedBox(),
        ],
      ),
    );
  }

  _getPicture() async {
//    await LocalImageProvider().initialize();
//    num start = DateTime.now().millisecondsSinceEpoch;
//    images = await LocalImageProvider().findLatest(10000000);
//    print(
//        "查询到${images?.length}张照片，用时${DateTime.now().millisecondsSinceEpoch - start}毫秒");
  }

  ///同步图片逻辑
  _syncPictures() async {
    if (mounted) {
      setState(() {});
    }
  }
}
