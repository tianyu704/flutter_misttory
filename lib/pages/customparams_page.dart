import 'package:flutter/material.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/customparams_helper.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/models/customparams.dart';

import '../location_config.dart';

enum CustomParamsType {
  timeInterval,///定位时间间隔 【1 * 60 * 000    30 * 60 * 1000】
  distanceFilter,///定位米数间隔 [2  1000 2000];
  storyRadiusMin,/// [2  10  50]
  storyRadiusMax,

  /// [50   200   1000]
  storyKeepingTimeMin,

  ///[1 *60 * 1000   30 * 60 * 1000]
  poiSearchInterval,

  ///[100  300 2000]
  pictureRadius,

  ///[50 100 3000]
  refreshHomePageTime,

  ///[15 60 60 * 2]
  judgeDistanceNum,

  ///两个间隔陌生地点距离边界 3000 [2000     5000]
}

class CustomParamsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CustomParamsPageState();
  }
}

class _CustomParamsPageState extends LifecycleState<CustomParamsPage> {
  double deviceWidth;
  Customparams params;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initData();
  }

  initData() async {
    params = await LocationConfig.updateDynamicData();
    if (params == null) {
      print("xxxxx");
      print(params);
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    Size screenSize = MediaQuery.of(context).size;

    deviceWidth = orientation == Orientation.portrait
        ? screenSize.width
        : screenSize.height;
    return Scaffold(
        appBar: AppBar(
          title: Text("Setting"),
          actions: <Widget>[
            Offstage(
              offstage: false,
              child: FlatButton(
                  onPressed: ()  {
                     CustomParamsHelper().createOrUpdate(params);
                     LocationConfig.updateDynamicData();
                     Navigator.pop(context);
                  },
                  child: Text("保存修改")),
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40,left: 20),
            child: Text("获取定位时间间隔（min）当前值为${params== null? LocationConfig.interval/1000/60 : params.timeInterval/1000/60}"),),
            cell(getInit(CustomParamsType.timeInterval),
                CustomParamsType.timeInterval),

            Padding(padding: EdgeInsets.only(top: 40,left: 20),
              child: Text("两个陌生点的距离（m）当前值 为${params == null? LocationConfig.judgeDistanceNum : params.judgeDistanceNum}"),),
            cell(getInit(CustomParamsType.judgeDistanceNum),
                CustomParamsType.judgeDistanceNum),
            Padding(padding: EdgeInsets.only(top: 40,left: 20),
              child: Text("poi搜索范围（m）当前值为 ${params == null ?LocationConfig.poiSearchInterval : params.poiSearchInterval}"),),
            cell(getInit(CustomParamsType.poiSearchInterval),
                CustomParamsType.poiSearchInterval),
            Padding(padding: EdgeInsets.only(top: 40,left: 20),
              child: Text("story 最短停留时长（min）当前值为 ${params == null ? LocationConfig.judgeUsefulLocation/1000/60 :params.storyKeepingTimeMin/1000/60}"),),
            cell(getInit(CustomParamsType.storyKeepingTimeMin),
                CustomParamsType.storyKeepingTimeMin),
            Padding(padding: EdgeInsets.only(top: 40,left: 20),
              child: Text("story 最大半径（m）当前值为 ${params == null ? LocationConfig.storyRadiusMax :params.storyRadiusMax}"),),
            cell(getInit(CustomParamsType.storyRadiusMax),
                CustomParamsType.storyRadiusMax),
            Padding(padding: EdgeInsets.only(top: 40,left: 20),
              child: Text("story 最小半径（m）当前值为 ${params == null ? LocationConfig.storyRadiusMin :params.storyRadiusMin}"),),
            cell(getInit(CustomParamsType.storyRadiusMin),
                CustomParamsType.storyRadiusMin),
            Padding(padding: EdgeInsets.only(top: 40,left: 20),
              child: Text("定位间隔距离（m）当前值为 ${params == null ? LocationConfig.distanceFilter :params.distanceFilter}"),),
            cell(getInit(CustomParamsType.distanceFilter),
                CustomParamsType.distanceFilter),
            Padding(padding: EdgeInsets.only(top: 40,left: 20),
              child: Text("图片区域半径（m）当前值为 ${params == null ? LocationConfig.pictureRadius :params.pictureRadius}"),),
            cell(getInit(CustomParamsType.pictureRadius),
                CustomParamsType.pictureRadius),
            Padding(padding: EdgeInsets.only(top: 40,left: 20),
              child: Text("首页更新时间 second 当前值为${params == null? LocationConfig.refreshTime : params.refreshHomePageTime}"),),
            cell(getInit(CustomParamsType.refreshHomePageTime),
                CustomParamsType.refreshHomePageTime),


            // buildSlider(getInit(CustomParamsType.judgeDistanceNum),CustomParamsType.judgeDistanceNum),
            //buildSlider(getInit(CustomParamsType.timeInterval),CustomParamsType.timeInterval),
          ],
        ));
  }

  Widget cell(num progressNum, CustomParamsType itemType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("${getMin(itemType)}"),
        buildSlider(getInit(itemType),
            itemType),
        Text("${getMax(itemType)}"),
      ],
    );
  }
  Widget buildSlider(num progressNum, CustomParamsType itemType) {
    return Slider(

      value: progressNum,
      label: "$progressNum",
      divisions: 50,
      onChanged: (initValue) {
        double value = initValue.roundToDouble();
        print(value);
        if (params != null)  {
          if (CustomParamsType.timeInterval == itemType) {
            print("赋值${value * 60 * 1000}");
            params.timeInterval = value * 60 * 1000;
          } else if (CustomParamsType.judgeDistanceNum == itemType) {
            params.judgeDistanceNum = value;
          } else if (CustomParamsType.poiSearchInterval == itemType) {
            params.poiSearchInterval = value ;
          } else if (CustomParamsType.storyKeepingTimeMin == itemType) {
            params.storyKeepingTimeMin = value * 60 * 1000;
          } else if (CustomParamsType.storyRadiusMax == itemType) {
            params.storyRadiusMax = value;
          } else if (CustomParamsType.distanceFilter == itemType) {
            params.distanceFilter = value;
          } else if (CustomParamsType.pictureRadius == itemType) {
            params.pictureRadius = value;
          } else if (CustomParamsType.refreshHomePageTime == itemType) {
            params.refreshHomePageTime = value;
          }  else if (CustomParamsType.storyRadiusMin  == itemType) {
            params.storyRadiusMin = value;
          }
        }
        setState(() {
        });
      },
      max: getMax(itemType),
      min: getMin(itemType),
    );
  }

  getInit(CustomParamsType itemType) {
    double value = 10;
    if (params == null) return value;
    if (CustomParamsType.timeInterval == itemType) {
      value = params.timeInterval /60 / 1000;
    } else if (CustomParamsType.judgeDistanceNum == itemType) {
      value = params.judgeDistanceNum;
    } else if (CustomParamsType.poiSearchInterval == itemType) {
      value = params.poiSearchInterval;
    } else if (CustomParamsType.storyKeepingTimeMin == itemType) {
      value = params.storyKeepingTimeMin/60/1000;
    } else if (CustomParamsType.storyRadiusMax == itemType) {
      value = params.storyRadiusMax;
    } else if (CustomParamsType.distanceFilter == itemType) {
      value = params.distanceFilter;
    } else if (CustomParamsType.pictureRadius == itemType) {
      value = params.pictureRadius;
    } else if (CustomParamsType.refreshHomePageTime == itemType) {
      value = params.refreshHomePageTime;
    }  else if (CustomParamsType.storyRadiusMin  == itemType) {
      value = params.storyRadiusMin;
    }
    return value;
  }

  getMax(CustomParamsType itemType) {
    double max = 3000;
    if (CustomParamsType.timeInterval == itemType) {
      max = 30  ;
    } else if (CustomParamsType.judgeDistanceNum == itemType) {
      max = 5000;
    } else if (CustomParamsType.poiSearchInterval == itemType) {
      max = 1000;
    } else if (CustomParamsType.storyKeepingTimeMin == itemType) {
      max = 30  ;
    } else if (CustomParamsType.storyRadiusMax == itemType) {
      max = 1000;
    } else if (CustomParamsType.distanceFilter == itemType) {
      max = 2000;
    } else if (CustomParamsType.pictureRadius == itemType) {
      max = 3000;
    } else if (CustomParamsType.refreshHomePageTime == itemType) {
      max = 60 * 2.0;
    } else if (CustomParamsType.storyRadiusMin  == itemType) {
      max = 49;
    }
    return max;
  }

  getMin(CustomParamsType itemType) {
    double value = 10;
    if (params == null) return value;
    if (CustomParamsType.timeInterval == itemType) {
      value = 1 ;
    } else if (CustomParamsType.judgeDistanceNum == itemType) {
      value = 2000;
    } else if (CustomParamsType.poiSearchInterval == itemType) {
      value = 100;
    } else if (CustomParamsType.storyKeepingTimeMin == itemType) {
      value = 1  ;
    } else if (CustomParamsType.storyRadiusMax == itemType) {
      value = 50;
    } else if (CustomParamsType.distanceFilter == itemType) {
      value = 2;
    } else if (CustomParamsType.pictureRadius == itemType) {
      value = 50;
    } else if (CustomParamsType.refreshHomePageTime == itemType) {
      value = 15;
    }
    else if (CustomParamsType.storyRadiusMin  == itemType) {
      value = 2;
    }
    return value;
  }
}
