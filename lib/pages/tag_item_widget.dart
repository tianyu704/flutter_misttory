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
    // TODO: implement build
    return SizedBox(
      width: size,
      child: FlatButton.icon(

        icon: Icon(Icons.info),
        label: Text("详情"),
        onPressed: (){
          debugPrint("$name");
        },
      ) //Text("$name",style:TextStyle(color: Colors.white,backgroundColor: Colors.blue),)
    );
  }
}