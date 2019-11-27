import 'package:flutter/material.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/db/helper/customparams_helper.dart';
import 'package:misstory/db/helper/location_db_helper.dart';
import 'package:misstory/db/helper/timeline_helper.dart';
import 'package:misstory/eventbus/event_bus_util.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/models/customparams.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/widgets/loading_dialog.dart';

import '../location_config.dart';

enum CustomParamsType {
  timeInterval,

  ///定位时间间隔 【1 * 60 * 000    30 * 60 * 1000】
  distanceFilter,

  ///定位米数间隔 [2  1000 2000];
  storyRadiusMin,

  /// [2  150]
  storyRadiusMax,

  /// [150   200   1000]
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
  aMapTypes,
  locationWebReqestType,

  ///高德poi类型
  /// 010000汽车服务、020000汽车销售、030000汽车维修、050000餐饮服务、060000购物服务、
  /// 070000生活服务、080000体育休闲、090000医疗保健服务、100000住宿服务、110000风景名胜
  /// 120000商务住宅、130000政府机构及社会团体、140000科教文化、150000交通设施、
  /// 160000金融保险、170000公司企业、180000道路附属设施、190000地名地址信息、200000公共设施
  ///220000事件活动、990000同行设施
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
  Map amapTypMap = {
    "010000": "汽车服务",
    "020000": "汽车销售",
    "030000": "汽车维修",
    "050000": "餐饮服务",
    "060000": "购物服务",
    "070000": "生活服务",
    "080000": "体育休闲",
    "090000": "医疗保险服务",
    "100000": "住宿服务",
    "110000": "风景名胜",
    "120000": "商务住宅",
    "130000": "政府机构及社会团体",
    "140000": "科教文化",
    "150000": "交通设施",
    "160000": "金融保险",
    "170000": "公司企业",
    "180000": "道路附属设施",
    "190000": "地名地址信息",
    "200000": "公共设施",
    "220000": "事件活动",
    "990000": "同行设施"
  };
  Map amapTypeCheckMap = {};
  List amapKeyList = [];
  String _newValue = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //
    for (String key in amapTypMap.keys) {
      amapKeyList.add(key);
    }
    initData();
  }

  initData() async {
    params = await LocationConfig.updateDynamicData();
    if (StringUtil.isNotEmpty(LocationConfig.aMapTypes)) {
      List list = LocationConfig.aMapTypes.split("|");
      for (String key in list) {
        amapTypeCheckMap[key] = true;
      }
    }
    _newValue = LocationConfig.locationWebReqestType;
    print(params.locationWebReqestType);

    if (params == null) {
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
                  onPressed: () async {
                    EventBusUtil.fireLocationEvent(0);
                    LoadingDialog loading = LoadingDialog(
                      outsideDismiss: false,
                      loadingText: "重新生成中Thinking...",
                    );
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return loading;
                        });
                    await Future.delayed(Duration(milliseconds: 500));

                    String str = "";
                    int i = 0;
                    for (String key in amapTypeCheckMap.keys) {
                      str = str + key;
                      if (i < amapTypeCheckMap.keys.length - 1) {
                        str = str + "|";
                      }
                      i++;
                    }
                    print("=======$str=====");
                    if (StringUtil.isNotEmpty(str)) {
                      params.aMapTypes = str;
                    }
                    params.locationWebReqestType = _newValue;
                    print(params.locationWebReqestType);
                    await CustomParamsHelper().createOrUpdate(params);
                    await LocationConfig.updateDynamicData();
                    await TimelineHelper().deleteLocationTimeline();
                    await LocationDBHelper().convertAllLocationToTimeline();
                    EventBusUtil.fireLocationEvent(1);

                    ///进度消失
                    loading.handleDismiss();
                    Navigator.pop(context);
                  },
                  child: Text("保存修改")),
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
              child: Text(
                  "获取定位时间间隔（min）当前值为${params == null ? LocationConfig.interval / 1000 / 60 : params.timeInterval / 1000 / 60}"),
            ),
            cell(CustomParamsType.timeInterval),

//            Padding(
//              padding: EdgeInsets.only(top: 40, left: 20),
//              child: Text(
//                  "两个陌生点的距离（m）当前值 为${params == null ? LocationConfig.judgeDistanceNum : params.judgeDistanceNum}"),
//            ),
//            cell(CustomParamsType.judgeDistanceNum),
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
              child: Text(
                  "poi搜索范围（m）当前值为 ${params == null ? LocationConfig.poiSearchInterval : params.poiSearchInterval}"),
            ),
            cell(CustomParamsType.poiSearchInterval),
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
              child: Text(
                  "story 最短停留时长（min）当前值为 ${params == null ? LocationConfig.judgeUsefulLocation / 1000 / 60 : params.storyKeepingTimeMin / 1000 / 60}"),
            ),
            cell(CustomParamsType.storyKeepingTimeMin),
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
              child: Text(
                  "story 最大半径（m）当前值为 ${params == null ? LocationConfig.locationMaxRadius : params.storyRadiusMax}"),
            ),
            cell(CustomParamsType.storyRadiusMax),
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
              child: Text(
                  "story 最小半径（m）当前值为 ${params == null ? LocationConfig.locationRadius : params.storyRadiusMin}"),
            ),
            cell(CustomParamsType.storyRadiusMin),
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
              child: Text(
                  "系统定位每隔${params == null ? LocationConfig.distanceFilter : params.distanceFilter}米定位一次"),
            ),
            cell(CustomParamsType.distanceFilter),
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
              child: Text(
                  "图片生成Story的半径，当前值为 ${params == null ? LocationConfig.pictureRadius : params.pictureRadius}米"),
            ),
            cell(CustomParamsType.pictureRadius),
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
              child: Text(
                  "首页刷新时间，当前值为${params == null ? LocationConfig.refreshTime : params.refreshHomePageTime}秒"),
            ),
            cell(CustomParamsType.refreshHomePageTime),

            Padding(
              padding: EdgeInsets.only(top: 40, left: 20),
              child: Text("Poi 推荐搜索类型"),
            ),
            Offstage(
              offstage: LocationWebReqestType.Tencent == LocationConfig.locationWebReqestType,
              child: buildWrapCheck(),
            ),
            Offstage(
              offstage: false,
              //LocationWebReqestType.Tencent != LocationConfig.locationWebReqestType,
              child: locationWebReqestType(),
            )

            // buildSlider(getInit(CustomParamsType.judgeDistanceNum),CustomParamsType.judgeDistanceNum),
            //buildSlider(getInit(CustomParamsType.timeInterval),CustomParamsType.timeInterval),
          ],
        ));
  }

  Widget cell(CustomParamsType itemType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("${getMin(itemType)}"),
        buildSlider(getInit(itemType), itemType),
        Text("${getMax(itemType)}"),
      ],
    );
  }

  Widget buildSlider(double progressNum, CustomParamsType itemType) {
    return Slider(
      value: progressNum,
      label: "${progressNum.toInt()}",
      divisions: 50,
      onChanged: (initValue) {
        int value = initValue.toInt();
        print(value);
        if (params != null) {
          if (CustomParamsType.timeInterval == itemType) {
            print("赋值${value * 60 * 1000}");
            params.timeInterval = value * 60 * 1000;
          } else if (CustomParamsType.judgeDistanceNum == itemType) {
            params.judgeDistanceNum = value;
          } else if (CustomParamsType.poiSearchInterval == itemType) {
            params.poiSearchInterval = value;
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
          } else if (CustomParamsType.storyRadiusMin == itemType) {
            params.storyRadiusMin = value;
          }
        }
        setState(() {});
      },
      max: getMax(itemType),
      min: getMin(itemType),
    );
  }

  buildWrapCheck() {
    return Wrap(
      spacing: 0, //主轴上子控件的间距
      runSpacing: 0, //交叉轴上子控件之间的间距
      children: Boxs(), //要显示的子控件集合
    );
  }

  /*一个渐变颜色的正方形集合*/
  List<Widget> Boxs() => List.generate(amapKeyList.length, (index) {
        String key = amapKeyList[index];
        bool _checkboxSelected =
            amapTypeCheckMap.containsKey(key) ? amapTypeCheckMap[key] : false;
        String title = amapTypMap[key];
        return SizedBox(
          width: deviceWidth / 2,
          child: CheckboxListTile(
            title: Text(title),
            value: _checkboxSelected,
            onChanged: (bool value) {
              setState(() {
                _checkboxSelected = value;
                amapTypeCheckMap[key] = value;
                if (!value) {
                  amapTypeCheckMap.remove(key);
                }
                print(amapTypeCheckMap);
              });
            },
          ),
        );
      });

  /*一个渐变颜色的正方形集合*/
  Widget locationWebReqestType() {
    List list = ["高德poi", "腾讯poi"];
    return Row(
      children: <Widget>[
        Flexible(
          child: RadioListTile<String>(
              value: LocationWebReqestType.AMap,
              title: Text(list[0]),
              groupValue: _newValue,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                });
              }),
        ),
        Flexible(
          child: RadioListTile<String>(
              value: LocationWebReqestType.Tencent,
              title: Text(list[1]),
              groupValue: _newValue,
              onChanged: (value) {
                setState(() {
                  _newValue = value;
                });
              }),
        ),

      ],
    );
  }

  getInit(CustomParamsType itemType) {
    num value = 10;
    if (params == null) return value.toDouble();
    if (CustomParamsType.timeInterval == itemType) {
      double v = params.timeInterval.toDouble() / 60 / 1000;
      value = v.toInt();
    } else if (CustomParamsType.judgeDistanceNum == itemType) {
      value = params.judgeDistanceNum;
    } else if (CustomParamsType.poiSearchInterval == itemType) {
      value = params.poiSearchInterval;
    } else if (CustomParamsType.storyKeepingTimeMin == itemType) {
      double v = params.storyKeepingTimeMin.toDouble() / 60 / 1000;
      value = v.toInt();
    } else if (CustomParamsType.storyRadiusMax == itemType) {
      value = params.storyRadiusMax;
    } else if (CustomParamsType.distanceFilter == itemType) {
      value = params.distanceFilter;
    } else if (CustomParamsType.pictureRadius == itemType) {
      value = params.pictureRadius;
    } else if (CustomParamsType.refreshHomePageTime == itemType) {
      value = params.refreshHomePageTime;
    } else if (CustomParamsType.storyRadiusMin == itemType) {
      value = params.storyRadiusMin;
    }
    return value.toDouble();
  }

  getMax(CustomParamsType itemType) {
    num max = 3000;
    if (CustomParamsType.timeInterval == itemType) {
      max = 30;
    } else if (CustomParamsType.judgeDistanceNum == itemType) {
      max = 5000;
    } else if (CustomParamsType.poiSearchInterval == itemType) {
      max = 1000;
    } else if (CustomParamsType.storyKeepingTimeMin == itemType) {
      max = 30;
    } else if (CustomParamsType.storyRadiusMax == itemType) {
      max = 1000;
    } else if (CustomParamsType.distanceFilter == itemType) {
      max = 2000;
    } else if (CustomParamsType.pictureRadius == itemType) {
      max = 3000;
    } else if (CustomParamsType.refreshHomePageTime == itemType) {
      max = 60 * 2;
    } else if (CustomParamsType.storyRadiusMin == itemType) {
      max = 150;
    }
    return max.toDouble();
  }

  getMin(CustomParamsType itemType) {
    int value = 10;
    if (params == null) return value.toDouble();
    if (CustomParamsType.timeInterval == itemType) {
      value = 1;
    } else if (CustomParamsType.judgeDistanceNum == itemType) {
      value = 2000;
    } else if (CustomParamsType.poiSearchInterval == itemType) {
      value = 100;
    } else if (CustomParamsType.storyKeepingTimeMin == itemType) {
      value = 1;
    } else if (CustomParamsType.storyRadiusMax == itemType) {
      value = 150;
    } else if (CustomParamsType.distanceFilter == itemType) {
      value = 2;
    } else if (CustomParamsType.pictureRadius == itemType) {
      value = 50;
    } else if (CustomParamsType.refreshHomePageTime == itemType) {
      value = 15;
    } else if (CustomParamsType.storyRadiusMin == itemType) {
      value = 2;
    }
    return value.toDouble();
  }
}
