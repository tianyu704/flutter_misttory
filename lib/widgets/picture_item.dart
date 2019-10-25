import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/models/picture.dart' as model;
import 'package:misstory/style/app_style.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/widgets/picture_widget.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-24
///
class PictureItem extends StatefulWidget {
  final String pictures;
  final Function onTap;

  PictureItem(this.pictures, this.onTap);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PictureItemState();
  }
}

class _PictureItemState extends LifecycleState<PictureItem> {
  final double space = 7;
  List<LocalImage> _images = List<LocalImage>();
  int _size = 0;
  double _width;
  double _pixelRatio;
  List<String> _ids;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pixelRatio = window.devicePixelRatio;
    _width = window.physicalSize.width / _pixelRatio - 80;
    if (!StringUtil.isEmpty(widget.pictures)) {
      //    _size = Random().nextInt(7);
      _ids = widget.pictures.split(",");
      debugPrint("========pictures=========$_ids");
      if (_ids != null && _ids.length > 0) {
        _size = _ids.length;
        if (_size > 6) _size = 6;
        initImages();
      }
    }
  }

  initImages() async {
    for (String id in _ids) {
      _images.add(switchLocalImage(await PictureHelper().queryPictureById(id)));
    }
    if (mounted) {
      setState(() {});
    }
  }

  LocalImage switchLocalImage(model.Picture picture) {
    print("========pictures=========${picture.toJson()}");
    return LocalImage(picture.id, picture.creationDate, picture.pixelWidth.toInt(),
        picture.pixelHeight.toInt(), picture.lon, picture.lat, picture.path, null);
  }

  @override
  Widget build(BuildContext context) {
    switch (_size ?? 0) {
      case 0:
        return Container(
          height: 0,
        );
        break;
      case 1:
        return _build1();
        break;
      case 2:
        return _build2();
        break;
      case 3:
        return _build3();
        break;
      case 4:
        return _build4();
        break;
      case 5:
        return _build5();
        break;
      case 6:
        return _build6();
        break;
    }
  }

  Widget _build1() {
    return _buildItem(_width, _width / 2, 0);
  }

  Widget _build2() {
    double width = (_width - space) / 2;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildItem(width, width, 0),
        Spacer(flex: 1),
        _buildItem(width, width, 1),
      ],
    );
  }

  Widget _build3() {
    double width1 = (_width - space) * 0.5714;
    double width2 = _width - width1 - space;
    double height2 = (width1 - space) / 2;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildItem(width1, width1, 0),
        Spacer(
          flex: 1,
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildItem(width2, height2, 1),
            SizedBox(height: space),
            _buildItem(width2, height2, 2),
          ],
        ),
      ],
    );
  }

  Widget _build4() {
    double width = (_width - space) / 2;
    double height = width * 5 / 7;
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildItem(width, height, 0),
            Spacer(flex: 1),
            _buildItem(width, height, 1),
          ],
        ),
        SizedBox(height: space),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildItem(width, height, 2),
            Spacer(flex: 1),
            _buildItem(width, height, 3),
          ],
        ),
      ],
    );
  }

  Widget _build5() {
    double width = (_width - space) / 2;
    double height = (_width - space * 2) / 3;
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          children: <Widget>[
            _buildItem(width, width, 0),
            SizedBox(height: space),
            _buildItem(width, width, 2),
          ],
        ),
        Spacer(flex: 1),
        Column(
          children: <Widget>[
            _buildItem(width, height, 1),
            SizedBox(height: space),
            _buildItem(width, height, 3),
            SizedBox(height: space),
            _buildItem(width, height, 4),
          ],
        ),
      ],
    );
  }

  Widget _build6() {
    double width = (_width - space) / 2;
    double height = (_width - space * 2) / 3;
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            _buildItem(width, height, 0),
            SizedBox(height: space),
            _buildItem(width, height, 2),
            SizedBox(height: space),
            _buildItem(width, height, 4),
          ],
        ),
        Spacer(flex: 1),
        Column(
          children: <Widget>[
            _buildItem(width, height, 1),
            SizedBox(height: space),
            _buildItem(width, height, 3),
            SizedBox(height: space),
            _buildItem(width, height, 5),
          ],
        ),
      ],
    );
  }

  Widget _buildItem(double width, double height, int index) {
    bool has = _images != null && index < _images.length;
    return SizedBox(
      width: width,
      height: height,
      child: has
          ? PictureWidget(
              _images[index],
              width: width * _pixelRatio * 1.5,
              height: height * _pixelRatio * 1.5,
              onTap: widget.onTap,
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
