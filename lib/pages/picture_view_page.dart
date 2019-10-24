import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/widgets/my_appbar.dart';
import 'package:misstory/widgets/picture.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-23
///
class PictureViewPage extends StatefulWidget {
  final List<LocalImage> images;
  final String title;
  final String subTitle;
  final int position;

  PictureViewPage(this.images, this.title, this.subTitle, {this.position = 0});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PictureViewPageState();
  }
}

class _PictureViewPageState extends LifecycleState<PictureViewPage> {
  PageController _pageController;
  int _currentIndex;
  List<LocalImage> _images;
  double _width, _height;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _width = window.physicalSize.width;
    _height = window.physicalSize.height * 7 / 10;
    _currentIndex = widget.position;
    _images = widget.images;
    _pageController =
        PageController(initialPage: _currentIndex, viewportFraction: 0.9999);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: MyAppbar(
        context,
        isHero: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Hero(
              tag: "date",
              child: Text(
                widget.title ?? "",
                style: AppStyle.mainText14(context, bold: true),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Hero(
              tag: "address",
              child: Text(
                widget.subTitle ?? "",
                style: AppStyle.mainText10(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppStyle.colors(context).colorBgPage,
      body: ExtendedImageGesturePageView.builder(
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        itemBuilder: _buildItem,
        canMovePage: (details) {
          return true;
        },
        itemCount: _images?.length ?? 0,
        onPageChanged: (index) {
          _currentIndex = index;
        },
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    LocalImage image = _images[index];
    return Picture(
      image,
      width: _width,
      height: _height,
      radius: 0,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }
}
