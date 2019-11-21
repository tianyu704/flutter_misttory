

import 'package:flutter/material.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'customparams_page.dart';

class LogPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LogPageState();
  }
}

class _LogPageState extends LifecycleState<LogPage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SettingDetail"),
        actions: <Widget>[
          Offstage(
            offstage: false,
            child: FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return CustomParamsPage();
                  }));
                },
                child: Text("settings")),
          ),
        ],
      ),
      body: Text("xxx"),
    );
  }

}