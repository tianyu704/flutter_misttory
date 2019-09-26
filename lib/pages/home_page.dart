import 'package:flutter/material.dart';
import 'package:flutter_amap_location_plugin/amap_location_lib.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:intl/intl.dart';

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
  List<Location> locations = List<Location>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int i = 0; i < 20; i++) {
      locations.add(Location()
        ..address = "北京市朝阳区百子湾路78-1号靠近中国建设银行(北京百子湾路支行)$i"
        ..aoiname = "金隅·大成国际中心"
        ..poiname = "中国建设银行(北京百子湾路支行)"
        ..lat = 39.90011388226134
        ..lon = 116.4927898889652
        ..time = 1569313349242);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("今天"),
      ),
      body: ListView.separated(
        itemBuilder: _buildItem,
        separatorBuilder: _buildSeparator,
        itemCount: locations?.length ?? 0,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }

  Widget _buildSeparator(context, index) {
    return SizedBox(
      height: 10,
    );
  }

  Widget _buildItem(context, index) {
    Location location = locations[index];
    String date = "";
    if (location?.time != null && location?.time != 0) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(location.time);
      date = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime);
    }
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("aoi:${location.aoiname}"),
            Text("poi:${location.poiname}"),
            Text("地址：${location.address}"),
            Text("经纬度:(${location.lon},${location.lat})"),
            Text("日期:$date"),
          ],
        ),
      ),
    );
  }
}
