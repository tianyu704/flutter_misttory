import 'package:flutter/material.dart';
import 'package:lifecycle_state/lifecycle_state.dart';

class PeopleTagPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PeopleTagPageState();
  }
}

class _PeopleTagPageState extends LifecycleState<PeopleTagPage> {

  ///人物
  TextEditingController _textFieldVC = TextEditingController();
  FocusNode _focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    // TODO:
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("编辑好友"),
      ),
      backgroundColor: Colors.white,
      body: Column(children: <Widget>[
          peopleTextField(context)
      ]),
    );
  }

  //人物编辑
  Widget peopleTextField(BuildContext context) {
    return SizedBox(
        height: 140,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: _textFieldVC,
            focusNode: _focusNode,
            enabled: true,
            minLines: 1,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: "输入好友",
            ),
            onEditingComplete: () {
              //TODO:监听输入完成触发
              _focusNode.unfocus();
              debugPrint("===${_textFieldVC.text}");
            },
          ),
//
        ));
  }


}
