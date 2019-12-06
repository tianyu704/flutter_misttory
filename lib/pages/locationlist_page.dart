import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/location_db_helper.dart';

import 'package:misstory/models/location.dart';
import 'package:misstory/models/timeline.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/utils/calculate_util.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LocationListPage extends StatefulWidget {
  final Timeline timeline;

  LocationListPage(this.timeline);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LocationListPageState();
  }
}

class _LocationListPageState extends LifecycleState<LocationListPage> {
  List<Location> _locations = List<Location>();
  WebViewController _webViewController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  initData() async {
    if (widget.timeline.uuid == null) {
      _locations = await LocationDBHelper().queryLocationsBetweenTime(
          widget.timeline.startTime, widget.timeline.endTime);
    } else {
      _locations = await LocationDBHelper()
          .queryLocationsWithTimelineId(widget.timeline.uuid);
    }

    if (_locations != null && _locations.length > 0) {
      setState(() {
        ///none
      });
      Future.delayed(Duration(seconds: 1), () {
        if (widget.timeline.uuid == null) {
          _webViewController
              ?.evaluateJavascript("setZoom(10)");
          Location location = _locations.last;
          var l = CalculateUtil.wgsToGcj(location.lat, location.lon);
          _webViewController
              ?.evaluateJavascript("setCenter(${l["lat"]},${l["lon"]})");
        } else {
          var l =
              CalculateUtil.wgsToGcj(widget.timeline.lat, widget.timeline.lon);
          _webViewController
              ?.evaluateJavascript("setCenter(${l["lat"]},${l["lon"]})");
        }
        for (Location location in _locations) {
          var l = CalculateUtil.wgsToGcj(location.lat, location.lon);
          _webViewController
              ?.evaluateJavascript("addMarker(${l["lat"]},${l["lon"]})");
        }
      });
    }
  }

  _notifySCurrentPage(value) {
    ///TODO：打碎整体重新开始计算
    print("打碎整体重新开始计算");
    initData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("LocationsList"),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: 250,
            child: WebView(
              initialUrl: "assets/html/gaode_map.html",
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (webViewController) {
                _webViewController = webViewController;
              },
              onPageFinished: (url) {
                _webViewController?.evaluateJavascript("setTouch(true)");
              },
            ),
          ),
          Flexible(
            child: ListView.separated(
              itemBuilder: _buildItem,
              separatorBuilder: _buildSeparator,
              itemCount: _locations?.length ?? 0,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator(context, index) {
    return SizedBox(
      height: 10,
    );
  }

  Widget _buildItem(context, index) {
    Location item = _locations[index];
    String date = "";
    if (item.time != null && item?.time != 0) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(item.time.toInt());
      date = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
    }
    return Card(
        clipBehavior: Clip.antiAlias,
        color: AppStyle.colors(context).colorBgCard,
        elevation: 0.1,
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("坐标:(${item.lat},${item.lon})"),
                Text("水平精度:${item.accuracy}(m)"),
                Text("垂直精度:${item.verticalAccuracy}（m）"),
                Text("速度:${item.speed}(m/s)"),
                Text("海拔:${item.altitude}"),
                Text("坐标类型:${item.coordType}"),
                Text("日期:$date"),
                Text("定位来源:${item.provider}"),
              ],
            ),
          ),
        ));
  }
}
