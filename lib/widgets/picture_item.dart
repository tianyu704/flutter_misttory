import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:misstory/models/picture.dart' as model;
import 'package:misstory/style/app_style.dart';
import 'package:misstory/widgets/picture_widget.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-24
///
class PictureItem extends StatelessWidget {
  final List<model.Picture> pictures;
  final Function onTap;

  PictureItem(this.pictures, this.onTap);

  final double space = 7;
  int _size = 0;
  double _width;
  double _pixelRatio;

  @override
  Widget build(BuildContext context) {
    _pixelRatio = window.devicePixelRatio;
    _width = window.physicalSize.width / _pixelRatio - 80;
    _size = pictures?.length ?? 0;
    if (_size > 6) {
      _size = 6;
    }
    switch (_size ?? 0) {
      case 0:
        return Container(
          width: 0,
          height: 0,
        );
        break;
      case 1:
        return _build1(context);
        break;
      case 2:
        return _build2(context);
        break;
      case 3:
        return _build3(context);
        break;
      case 4:
        return _build4(context);
        break;
      case 5:
        return _build5(context);
        break;
      case 6:
        return _build6(context);
        break;
    }
    return Text("");
  }

  Widget _build1(BuildContext context) {
    return _buildItem(context, _width, _width / 2, 0);
  }

  Widget _build2(BuildContext context) {
    double width = (_width - space) / 2;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildItem(context, width, width, 0),
        Spacer(flex: 1),
        _buildItem(context, width, width, 1),
      ],
    );
  }

  Widget _build3(BuildContext context) {
    double width1 = (_width - space) * 0.5714;
    double width2 = _width - width1 - space;
    double height2 = (width1 - space) / 2;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildItem(context, width1, width1, 0),
        Spacer(
          flex: 1,
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildItem(context, width2, height2, 1),
            SizedBox(height: space),
            _buildItem(context, width2, height2, 2),
          ],
        ),
      ],
    );
  }

  Widget _build4(BuildContext context) {
    double width = (_width - space) / 2;
    double height = width * 5 / 7;
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildItem(context, width, height, 0),
            Spacer(flex: 1),
            _buildItem(context, width, height, 1),
          ],
        ),
        SizedBox(height: space),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildItem(context, width, height, 2),
            Spacer(flex: 1),
            _buildItem(context, width, height, 3),
          ],
        ),
      ],
    );
  }

  Widget _build5(BuildContext context) {
    double width = (_width - space) / 2;
    double height = (_width - space * 2) / 3;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          children: <Widget>[
            _buildItem(context, width, width, 0),
            SizedBox(height: space),
            _buildItem(context, width, width, 2),
          ],
        ),
        Spacer(flex: 1),
        Column(
          children: <Widget>[
            _buildItem(context, width, height, 1),
            SizedBox(height: space),
            _buildItem(context, width, height, 3),
            SizedBox(height: space),
            _buildItem(context, width, height, 4),
          ],
        ),
      ],
    );
  }

  Widget _build6(BuildContext context) {
    double width = (_width - space) / 2;
    double height = (_width - space * 2) / 3;
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            _buildItem(context, width, height, 0),
            SizedBox(height: space),
            _buildItem(context, width, height, 2),
            SizedBox(height: space),
            _buildItem(context, width, height, 4),
          ],
        ),
        Spacer(flex: 1),
        Column(
          children: <Widget>[
            _buildItem(context, width, height, 1),
            SizedBox(height: space),
            _buildItem(context, width, height, 3),
            SizedBox(height: space),
            _buildItem(context, width, height, 5),
          ],
        ),
      ],
    );
  }

  Widget _buildItem(
      BuildContext context, double width, double height, int index) {
    bool has = pictures != null && index < pictures.length;
    return SizedBox(
      width: width,
      height: height,
      child: has
          ? PictureWidget(
              pictures[index],
              width: width * _pixelRatio * 1.5,
              height: height * _pixelRatio * 1.5,
              onTap: onTap,
            )
          : Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                  color: AppStyle.colors(context).colorPicBg,
                  borderRadius: BorderRadius.all(Radius.circular(6))),
            ),
    );
  }
}
