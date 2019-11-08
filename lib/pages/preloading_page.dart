import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/db/local_storage.dart';
import 'package:misstory/eventbus/event_bus_util.dart';
import 'package:misstory/eventbus/refresh_progress.dart';
import 'package:misstory/pages/home_page.dart';
import 'package:misstory/style/app_style.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-26
///
class PreLoadingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PreLoadingPageState();
  }
}

class _PreLoadingPageState extends LifecycleState<PreLoadingPage> {
  StreamSubscription _refreshSubscription;
  int count = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshSubscription = EventBusUtil.listen<RefreshProgress>((refreshDay) async {
      count++;
      if (count > 50) {
        LocalStorage.saveBool(LocalStorage.isStep, true);
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      }
    });
    _createPictures();
  }

  _createPictures() async {
    await PictureHelper().checkSystemPicture();
    if (await PictureHelper().getPictureSyc() > 50) {
      LocalStorage.saveBool(LocalStorage.isStep, true);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return HomePage();
      }));
      await PictureHelper().checkUnSyncedPicture();
    } else {
      await PictureHelper().checkUnSyncedPicture();
      if (mounted) {
        LocalStorage.saveBool(LocalStorage.isStep, true);
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyle.colors(context).colorBgPage,
        elevation: 0,
      ),
      body: Container(
        alignment: Alignment.center,
        color: AppStyle.colors(context).colorBgPage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 50,
              height: 30,
              child: LoadingIndicator(indicatorType: Indicator.ballPulse),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 30),
              child: Text(
                '''正在根据您的相册为您生成故事，请稍后！
耗时可能比较长，取决于您的图片数量''',
                style: AppStyle.mainText14(context),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _refreshSubscription.cancel();
    super.dispose();
  }
}
