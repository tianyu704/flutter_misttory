import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:local_image_provider/local_image_provider.dart';
import 'package:misstory/db/helper/picture_helper.dart';

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
                child: RaisedButton(
                  onPressed: () async {
                    if (images != null && images.length > 0) {
                      LatLng latlng = await CalculateTools().convertCoordinate(lat: images[0].lat, lon: images[0].lon, type: LatLngType.gps);
                      print(latlng.toJson());
                      //39°53'56.118",116°29'11.964"
                      //39.898923,116.48666

                      _aMapSearch
                          .searchReGeocode(latlng, 100, 1)
                          .then((result) {
                        _result = result.regeocodeAddress.toString();
                        debugPrint(_result);
                        setState(() {});
                      });
                    }
                  },
                  child: Text("获取"),
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
        SliverToBoxAdapter (child:
          RaisedButton(
              child: Text("测试存储Picture"),
              onPressed: (){
                _syncPictures();
          })

          ,),
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
  _syncPictures () async{


    if (mounted) {
      setState(() {});
    }
  }
}
