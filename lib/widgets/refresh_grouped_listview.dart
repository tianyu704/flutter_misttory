library grouped_listview;

import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:misstory/db/helper/picture_helper.dart';
import 'package:misstory/models/picture.dart';
import 'package:misstory/style/app_style.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef TGroup GroupFunction<TElement, TGroup>(TElement element);
typedef Widget ListBuilderFunction<TElement>(
    BuildContext context, TElement element);
typedef Widget GroupBuilderFunction<TGroup>(BuildContext context, TGroup group);

class RefreshGroupedListView<TElement, TGroup> extends StatelessWidget {
  final List<TElement> collection;
  final GroupFunction<TElement, TGroup> groupBy;
  final ListBuilderFunction<TItem<TElement>> listBuilder;
  final GroupBuilderFunction<TGroup> groupBuilder;

  final List<dynamic> _flattenedList = List();
  final RefreshController controller;
  final VoidCallback onLoading;

  RefreshGroupedListView(this.controller,
      {@required this.collection,
      @required this.groupBy,
      @required this.listBuilder,
      @required this.groupBuilder,
      this.onLoading}) {
    _flattenedList
        .addAll(Grouper<TElement, TGroup>().groupList(collection, groupBy));
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: false,
      enablePullUp: true,
      controller: controller,
      onLoading: onLoading,
      footer: CustomFooter(builder: (BuildContext context, LoadStatus mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          if (PictureHelper().isPictureConverting) {
            body =
                Text("正在生成时间轴,请稍后...", style: AppStyle.descText12(context));
          } else {
            body = Text("上拉加载", style: AppStyle.descText12(context));
          }
        } else if (mode == LoadStatus.loading) {
          body = SizedBox(
            height: 30,
            child: LoadingIndicator(indicatorType: Indicator.ballPulse),
          );
        } else if (mode == LoadStatus.failed) {
          body = Text("加载失败！点击重试！", style: AppStyle.descText12(context));
        } else if (mode == LoadStatus.canLoading) {
          body = Text("松手,加载更多!", style: AppStyle.descText12(context));
        } else {
          if (PictureHelper().isPictureConverting) {
            body = Text("正在生成时间轴,请稍后...", style: AppStyle.descText12(context));
          } else {
            body = Text("没有更多数据了!", style: AppStyle.descText12(context));
          }
        }
        return Container(
          height: 55.0,
          child: Center(child: body),
        );
      }),
      child: ListView.builder(
        itemBuilder: (context, index) {
          var element = _flattenedList[index];
          if (element is TItem) {
            return listBuilder(context, element);
          }
          return groupBuilder(context, element);
        },
        itemCount: _flattenedList.length,
        physics: BouncingScrollPhysics(),
      ),
    );
  }
}

class Grouper<TElement, TGroup> {
  final Map<TGroup, List<TItem<TElement>>> _groupedList = {};

  List<dynamic> groupList(
      List<TElement> collection, GroupFunction<TElement, TGroup> groupBy) {
    if (collection == null) throw ArgumentError("Collection can not be null");
    if (groupBy == null)
      throw ArgumentError("GroupBy function can not be null");

    List flattenedList = List();
    var lastKey;
    collection.forEach((element) {
      var key = groupBy(element);
      if (!_groupedList.containsKey(key)) {
        if (lastKey != null) {
          TItem item = _groupedList[lastKey][_groupedList[lastKey].length - 1];
          if (item.position == ItemPosition.START) {
            item.position = ItemPosition.ALL;
          } else {
            item.position = ItemPosition.END;
          }
        }
        _groupedList[key] = List<TItem<TElement>>();
        _groupedList[key].add(TItem(ItemPosition.START, element));
      } else {
        _groupedList[key].add(TItem(ItemPosition.CENTER, element));
      }
      lastKey = key;
    });
    if (lastKey != null) {
      TItem item = _groupedList[lastKey][_groupedList[lastKey].length - 1];
      if (item.position == ItemPosition.START) {
        item.position = ItemPosition.ALL;
      } else {
        item.position = ItemPosition.END;
      }
    }
    _groupedList.forEach((key, list) {
      flattenedList.add(key);
      flattenedList.addAll(list);
    });
    return flattenedList;
  }
}

class TItem<TElement> {
  ItemPosition position;
  TElement tElement;

  TItem(this.position, this.tElement);
}

enum ItemPosition { START, CENTER, END, ALL }
