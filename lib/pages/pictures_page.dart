import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:local_image_provider/local_image_provider.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/models/picture.dart' as model;
import 'package:misstory/models/story.dart';
import 'package:misstory/pages/picture_view_page.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/utils/date_util.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/widgets/my_appbar.dart';
import 'package:misstory/widgets/picture_widget.dart';

import 'edit_page.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-21
///
class PicturesPage extends StatefulWidget {
  final Story story;

  PicturesPage(this.story);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PicturesPage();
  }
}

class _PicturesPage extends LifecycleState<PicturesPage> {
  Story _story;
  String _address = "";
  String _title = "";
  double width;
  dynamic _result;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    width = (window.physicalSize.width - 34 * window.devicePixelRatio) / 4;
    print("===========$width");
    initData();
  }

  initData() async {
    _story = widget.story;
    if (_story != null) {
      _title = DateUtil.getMonthDayHourMin(_story.createTime);
      _address =
          "${StringUtil.isEmpty(_story.customAddress) ? _story.defaultAddress : _story.customAddress}，${_story.city}${_story.district}";
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: MyAppbar(
        context,
        title: Hero(
          tag: "date",
          child: Text(
            _title,
            style: AppStyle.mainText17(context, bold: true),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        leftIcon: MaterialButton(
          child: SvgPicture.asset(
            "assets/images/icon_back.svg",
          ),
          shape: CircleBorder(
            side: BorderSide(
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop(_result);
          },
        ),
        isHero: true,
      ),
      backgroundColor: AppStyle.colors(context).colorBgPage,
      body: Column(
        children: <Widget>[
          _buildHeader(),
          Expanded(
            flex: 1,
            child: _buildGrid(),
          ),
        ],
      ),
    );
  }

  /// 头部
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 0),
      height: 44,
      width: double.infinity,
      color: AppStyle.colors(context).colorBgCard,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Hero(
                tag: "address",
                child: Text(
                  _address,
                  style: AppStyle.mainText16(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(
              width: 44,
              height: 44,
              child: MaterialButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => EditPage(_story)))
                      .then(
                    (value) {
                      _result = value;
                    },
                  );
                },
                padding: EdgeInsets.all(0),
                child: SvgPicture.asset("assets/images/icon_edit.svg"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 图片列表
  Widget _buildGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4),
      itemBuilder: _buildItem,
      scrollDirection: Axis.vertical,
      itemCount: widget.story?.pictureList?.length ?? 0,
      padding: EdgeInsets.all(10),
    );
  }

  ///图片子元素
  Widget _buildItem(context, index) {
    model.Picture image = widget.story?.pictureList[index];
    return Hero(
      tag: image.id,
      child: PictureWidget(
        image,
        width: width,
        height: width,
        radius: 6,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PictureViewPage(
                widget.story?.pictureList,
                _title,
                _address,
                position: index,
              ),
            ),
          );
        },
      ),
    );
  }
}
