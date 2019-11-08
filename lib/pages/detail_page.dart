import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/models/latlonpoint.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/widgets/location_item.dart';
import 'package:misstory/widgets/my_appbar.dart';

import 'edit_page.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-11-08
///
class DetailPage extends StatefulWidget {
  final List<Story> stories;

  DetailPage(this.stories);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DetailPage();
  }
}

class _DetailPage extends LifecycleState<DetailPage> {
  AMapController _controller;
  MyLocationStyle _myLocationStyle;
  PolylineOptions _polylineOptions;
  List<LatLng> _latLngList = [];
  List<Story> _stories;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stories = widget.stories;
    _initLatLngList();
  }

  _initLatLngList() async {
    await Future.delayed(Duration(milliseconds: 500), () {
      for (Story story in widget.stories) {
        _latLngList.add(LatLng(story.lat, story.lon));
      }
    });
//    List<Latlonpoint> points = await LocationHelper().queryPoints(
//        _stories[_stories.length - 1].createTime, _stories[0].createTime);
//    for (Latlonpoint point in points) {
//      _latLngList.add(LatLng(point.latitude, point.longitude));
//    }
    _polylineOptions = PolylineOptions(
      latLngList: _latLngList,
      width: 30,
      color: AppStyle.colors(context).colorPrimary,
      isUseTexture: true,
      isUseGradient: true,
      isDottedLine: true,
      isGeodesic: true,
      dottedLineType: PolylineOptions.DOTTED_LINE_TYPE_CIRCLE,
      lineJoinType: PolylineOptions.LINE_JOIN_ROUND,
      lineCapType: PolylineOptions.LINE_CAP_TYPE_ARROW,
    );
    _controller?.addPolyline(_polylineOptions);
    _controller?.zoomToSpan(_latLngList);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: MyAppbar(
        context,
        title: Text(
          "途经地点",
          style: AppStyle.mainText17(context),
        ),
      ),
      body: Column(
        children: <Widget>[
          locationMapView(context),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemBuilder: _buildItem,
              itemCount: widget.stories?.length ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    Story story = widget.stories[index];
    String date = "";
    if (story?.createTime != null && story.createTime != 0) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(story.createTime.toInt());
      date = DateFormat("HH:mm").format(dateTime);
    }
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              date,
              style: AppStyle.mainText14(context),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              flex: 1,
              child: Text(
                getShowAddressText(story),
                style: AppStyle.mainText14(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => EditPage(story)))
            .then(
          (value) {
            if (value != null) {
              if (value is Story) {
                Story story = value;
                notifyDeleteStory(story);
                return;
              }
              if (value is List && value.length > 0) {
                Map<num, Story> stories = value[0];
                if (stories != null && stories.length > 0) {
                  notifyStories(stories);
                }
              }
            }
          },
        );
      },
    );
  }

  Widget locationMapView(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: AMapView(
        onAMapViewCreated: (controller) {
          ///``添加坐标点 地图图钉📌
          _controller = controller;

//          _controller.addMarker(MarkerOptions(
//            position: _currentLatLng,
//          ));
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
//          _controller.setZoomLevel(17);
          if (_polylineOptions != null &&
              _latLngList != null &&
              _latLngList.length > 0) {
            _controller?.addPolyline(_polylineOptions);
            _controller?.zoomToSpan(_latLngList);
          }
        },
        amapOptions: AMapOptions(
          compassEnabled: false,
          zoomControlsEnabled: true,
          logoPosition: LOGO_POSITION_BOTTOM_CENTER,
//          camera: CameraPosition(
//            zoom: 17,
//          ),
        ),
      ),
    );
  }

  ///从编辑页面返回后的刷新
  notifyStories(Map<num, Story> stories) {
    if (_stories != null && _stories.length > 0) {
      _stories.forEach((item) {
        if (stories.containsKey(item.id)) {
          //print("${stories[item.id].writeAddress}");
          item.lat = stories[item.id].lat;
          item.lon = stories[item.id].lon;
          item.customAddress = stories[item.id].customAddress;
          item.desc = stories[item.id].desc;
          item.writeAddress = stories[item.id].writeAddress;
        }
      });
      if (mounted) {
        setState(() {});
      }
    }
  }

  notifyDeleteStory(Story story) {
    if (_stories != null && _stories.length > 0) {
      _stories.removeWhere((item) => item.id == story.id);
      debugPrint("+++刷新删除完成++");
      if (mounted) {
        setState(() {});
      }
    }
  }

  getShowAddressText(Story story) {
    if (StringUtil.isNotEmpty(story.writeAddress)) {
      return story.writeAddress;
    }
    if (StringUtil.isNotEmpty(story.customAddress)) {
      return story.customAddress;
    }
    return story.defaultAddress;
  }
}
