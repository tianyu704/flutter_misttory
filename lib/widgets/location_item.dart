import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/style/app_style.dart';
import 'package:misstory/utils/date_util.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/widgets/refresh_grouped_listview.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-24
///
class LocationItem extends StatelessWidget {
  final TItem<Story> item;
  final Function onPressCard;
  final Function onPressPicture;

  LocationItem(this.item, {this.onPressCard, this.onPressPicture});

  @override
  Widget build(BuildContext context) {
    Story story = item.tElement;
    String date = "";
    if (story?.createTime != null && story.createTime != 0) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(story.createTime.toInt());
      date = DateFormat("HH:mm").format(dateTime);
    }
    // TODO: implement build
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.only(left: 24, top: 0, bottom: 0, right: 24),
      color: AppStyle.colors(context).colorBgCard,
      shape: _getShape(item),
      elevation: 0,
      child: InkWell(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 56,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            "$date",
                            style: AppStyle.mainText14(context),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          child: FlatButton(
                            onPressed: onPressPicture,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: SvgPicture.asset(
                                StringUtil.isEmpty(story.customAddress)
                                    ? "assets/images/icon_location_empty.svg"
                                    : "assets/images/icon_location_fill.svg",
                                width: 14,
                                height: 14,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  StringUtil.isEmpty(story.customAddress)
                                      ? story.defaultAddress
                                      : story.customAddress,
                                  maxLines: 2,
                                  style: AppStyle.mainText14(context,
                                      weight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            SvgPicture.asset(
                              "assets/images/icon_remain_time.svg",
                              width: 12,
                              height: 12,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 11),
                              child: Text(
                                DateUtil.getStayShowTime(story.intervalTime),
                                style: AppStyle.descText12(context),
                              ),
                            ),
                          ],
                        ),
                        Offstage(
                          offstage: StringUtil.isEmpty(story.desc),
                          child: Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              story?.desc ?? "",
                              style: AppStyle.contentText12(context),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Offstage(
              offstage: item.position == ItemPosition.END ||
                  item.position == ItemPosition.ALL,
              child: Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                color: AppStyle.colors(context).colorLine,
              ),
            ),
          ],
        ),
        onTap: onPressCard,
      ),
    );
  }

  ShapeBorder _getShape(TItem tItem) {
    switch (tItem.position) {
      case ItemPosition.START:
        return RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)));
        break;
      case ItemPosition.CENTER:
        return RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)));
        break;
      case ItemPosition.END:
        return RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)));
        break;
      case ItemPosition.ALL:
        return RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)));
        break;
    }
  }
}