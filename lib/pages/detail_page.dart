import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/location_helper.dart';
import 'package:misstory/models/latlonpoint.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/models/timeline.dart';
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
  final List<Timeline> timelines;

  DetailPage(this.timelines);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DetailPage();
  }
}

class _DetailPage extends LifecycleState<DetailPage> {
  AMapController _controller;
  MyLocationStyle _myLocationStyle;

//  PolylineOptions _polylineOptions;
  List<LatLng> _latLngList = [];
  List<Timeline> _timelines;
  List<MarkerOptions> _markerOptions = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timelines = widget.timelines;
    _initLatLngList();
  }

  _initLatLngList() async {
//    await Future.delayed(Duration(milliseconds: 500), () {
//      LatLng latLng;
//      for (Story story in widget.stories) {
//        latLng = LatLng(story.lat, story.lon);
//        _latLngList.add(latLng);
//        _markerOptions
//            .add(MarkerOptions(position: latLng));
//      }
//    });
    List<Latlonpoint> points = await LocationHelper().queryPoints(
        _timelines[_timelines.length - 1].startTime, _timelines[0].endTime);
    LatLng latLng;
    for (Latlonpoint point in points) {
      latLng = LatLng(point.latitude, point.longitude);
      _latLngList.add(latLng);
      _markerOptions.add(MarkerOptions(position: latLng));
    }
//    _polylineOptions = PolylineOptions(
//      latLngList: _latLngList,
//      width: 30,
//      color: AppStyle
//          .colors(context)
//          .colorPrimary,
//      isUseTexture: true,
//      isUseGradient: true,
//      isDottedLine: true,
//      isGeodesic: true,
//      dottedLineType: PolylineOptions.DOTTED_LINE_TYPE_CIRCLE,
//      lineJoinType: PolylineOptions.LINE_JOIN_ROUND,
//      lineCapType: PolylineOptions.LINE_CAP_TYPE_ARROW,
//    );
//    _controller?.addPolyline(_polylineOptions);
    _controller?.addMarkers(_markerOptions);
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
              itemCount: widget.timelines?.length ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    Timeline timeline = widget.timelines[index];
    String date = "";
    if (timeline?.startTime != null && timeline.startTime != 0) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(timeline.startTime.toInt());
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
                getShowAddressText(timeline),
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
            .push(MaterialPageRoute(builder: (context) => EditPage(timeline)))
            .then(
          (value) {
            if (value != null) {
              if (value is Timeline) {
                Timeline timeline = value;
                notifyDeleteStory(timeline);
                return;
              }
              if (value is List && value.length > 0) {
                Map<num, Timeline> timelines = value[0];
                if (timelines != null && timelines.length > 0) {
                  notifyStories(timelines);
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
            showsAccuracyRing: true,

            ///false 否则不能显示目标地点为中心点
          );
          _controller.setUiSettings(UiSettings(
            isMyLocationButtonEnabled: false,
            logoPosition: LOGO_POSITION_BOTTOM_LEFT,
            isZoomControlsEnabled: false,
          ));
          _controller.setMyLocationStyle(_myLocationStyle);
//          _controller.setZoomLevel(17);
          if (_markerOptions != null &&
              _latLngList != null &&
              _latLngList.length > 0) {
//            _controller?.addPolyline(_polylineOptions);
            _controller.addMarkers(_markerOptions);
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
  notifyStories(Map<num, Timeline> timelines) {
    if (_timelines != null && _timelines.length > 0) {
      _timelines.forEach((item) {
        if (timelines.containsKey(item.uuid)) {
          //print("${stories[item.id].writeAddress}");
          item.lat = timelines[item.uuid].lat;
          item.lon = timelines[item.uuid].lon;
          item.customAddress = timelines[item.uuid].customAddress;
          item.desc = timelines[item.uuid].desc;
          item.customAddress = timelines[item.uuid].customAddress;
        }
      });
      if (mounted) {
        setState(() {});
      }
    }
  }

  notifyDeleteStory(Timeline timeline) {
    if (_timelines != null && _timelines.length > 0) {
      _timelines.removeWhere((item) => item.uuid == timeline.uuid);
      debugPrint("+++刷新删除完成++");
      if (mounted) {
        setState(() {});
      }
    }
  }

  getShowAddressText(Timeline timeline) {
//    if (StringUtil.isNotEmpty(timeline.writeAddress)) {
//      return timeline.writeAddress;
//    }
    if (StringUtil.isNotEmpty(timeline.customAddress)) {
      return timeline.customAddress;
    }
    return timeline.poiName;
  }
}
