import 'package:flutter/material.dart';

class TagItemWidget extends StatelessWidget {
  final double size;
  final String name;

  TagItemWidget({
    Key key,
    this.size = 40,
    this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputChip(
        clipBehavior: Clip.antiAlias,
        label: Text(name,style: TextStyle(fontSize: 16),),
        deleteIcon: Icon(
          Icons.close,
          color: Colors.white,
          size: 16.0,
        ),
        deleteIconColor: Colors.white,
        //deleteButtonTooltipMessage: "弹出提示",
        labelStyle: TextStyle(color: Colors.white),
        backgroundColor: Colors.blue,
        onDeleted: () {

        },
        onPressed: () {

        });
  }
}