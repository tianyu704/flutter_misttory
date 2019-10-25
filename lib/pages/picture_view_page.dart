import 'dart:math';
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
        PageController(initialPage: _currentIndex, viewportFraction: 1);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ExtendedImageSlidePage(
      child: Scaffold(
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
//        backgroundColor: AppStyle.colors(context).colorBgPage,
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
      ),
      slideAxis: SlideAxis.both,
      slideType: SlideType.onlyImage,
      resetPageDuration: Duration(milliseconds: 300),
      onSlidingPage: (state){

      },
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    LocalImage image = _images[index];
    return Hero(
      tag: image.id,
      child: Picture(
        image,
        width: _width,
        height: _height,
        radius: 0,
        fit: BoxFit.contain,
        mode: ExtendedImageMode.gesture,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }

//  Color defaultSlidePageBackgroundHandler(
//      {Offset offset, Size pageSize, Color color, SlideAxis pageGestureAxis}) {
//    double opacity = 0.0;
//    if (pageGestureAxis == SlideAxis.both) {
//      opacity = offset.distance /
//          (Offset(pageSize.width, pageSize.height).distance / 2.0);
//    } else if (pageGestureAxis == SlideAxis.horizontal) {
//      opacity = offset.dx.abs() / (pageSize.width / 2.0);
//    } else if (pageGestureAxis == SlideAxis.vertical) {
//      opacity = offset.dy.abs() / (pageSize.height / 2.0);
//    }
//    return color.withOpacity(min(1.0, max(1.0 - opacity, 0.0)));
//  }
//
//  bool defaultSlideEndHandler(
//      {Offset offset, Size pageSize, SlideAxis pageGestureAxis}) {
//    if (pageGestureAxis == SlideAxis.both) {
//      return offset.distance >
//          Offset(pageSize.width, pageSize.height).distance / 3.5;
//    } else if (pageGestureAxis == SlideAxis.horizontal) {
//      return offset.dx.abs() > pageSize.width / 3.5;
//    } else if (pageGestureAxis == SlideAxis.vertical) {
//      return offset.dy.abs() > pageSize.height / 3.5;
//    }
//    return true;
//  }
//
//  double defaultSlideScaleHandler(
//      {Offset offset, Size pageSize, SlideAxis pageGestureAxis}) {
//    double scale = 0.0;
//    if (pageGestureAxis == SlideAxis.both) {
//      scale = offset.distance / Offset(pageSize.width, pageSize.height).distance;
//    } else if (pageGestureAxis == SlideAxis.horizontal) {
//      scale = offset.dx.abs() / (pageSize.width / 2.0);
//    } else if (pageGestureAxis == SlideAxis.vertical) {
//      scale = offset.dy.abs() / (pageSize.height / 2.0);
//    }
//    return max(1.0 - scale, 0.8);
//  }
}
