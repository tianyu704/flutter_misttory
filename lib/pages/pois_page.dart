import 'package:flutter/material.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-09-27
///
class PoisPage extends StatelessWidget {
  final String json;

  PoisPage(this.json);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Pois"),
      ),
      body: Text(json),
    );
  }
}
