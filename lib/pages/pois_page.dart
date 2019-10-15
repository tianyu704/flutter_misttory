import 'package:flutter/material.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-09-27
///
class PoisPage extends StatelessWidget {
  final String json;
  TextEditingController _controller;
  ScrollController _scrollController = ScrollController();

  PoisPage(this.json);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Pois"),
      ),
      body: CustomScrollView(
        controller: _scrollController,

        slivers: <Widget>[
          //AppBar，包含一个导航栏
          SliverAppBar(
            pinned: true,
            elevation: 0,
            floating: true,
            bottom: PreferredSize(
              child: Container(
                color: Colors.red,
                height: 100,
              ),
              preferredSize: Size(double.infinity, 100),
            ),
            centerTitle: true,
            expandedHeight: 250,
            leading: Text(""),
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    maxLines: 5,
                    scrollPhysics: BouncingScrollPhysics(),
                  ),
                ),
              ),
            ),
          ),

          //List
          new SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: new SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                //创建列表项
                return new Container(
                  alignment: Alignment.center,
                  color: Colors.lightBlue[100 * (index % 9)],
                  child: new Text('list item $index'),
                );
              },
              childCount: 50, //50个列表项
            ),
          ),
        ],
      ),
    );
  }
}
