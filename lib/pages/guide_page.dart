import 'package:flutter/material.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/style/app_style.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-12-06
///
class GuidePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GuidePageState();
  }
}

class _GuidePageState extends LifecycleState<GuidePage>{
  bool _locationPermisstion = false;
  bool _netPermisstion = false;
  bool _picturePermisstion = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: AppStyle.colors(context).colorBgPage,
      body: Column(
        children: <Widget>[
          Text("欢迎使用，简单的几个点击，你就可以自动记录自己的生活啦，我们开始吧"),
          ListView(
            children: <Widget>[
              CheckboxListTile(
                title: Text("位置（必选），我们必需获得位置授权，才能记录数据，（iOS要提示用户将权限设置为always，并且进行逻辑验证后）"),
                value: _locationPermisstion,
                onChanged: (bool value) {
                  setState(() {
                    _locationPermisstion = value;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("联网 （必选，仅iOS， 通过网络获取相关地点信息）"),
                value: _locationPermisstion,
                onChanged: (bool value) {
                  setState(() {
                    _locationPermisstion = value;
                  });
                },
              ),
              CheckboxListTile(
                title: Text("欢迎使用，简单的几个点击，你就可以自动记录自己的生活啦，我们开始吧"),
                value: _locationPermisstion,
                onChanged: (bool value) {
                  setState(() {
                    _locationPermisstion = value;
                  });
                },
              ),
            ],
          ),

        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}