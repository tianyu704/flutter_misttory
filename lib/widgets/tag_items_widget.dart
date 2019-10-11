import 'package:flutter/material.dart';
import 'package:misstory/utils/string_util.dart';


typedef ClickTagItemCallback = void Function(String name);
typedef ClickKeyboardCallback = void Function(String name);

class TagItemsWidget extends StatelessWidget {
  final List list;
  final String placeholder;
  final ClickTagItemCallback clickTagItemCallAction;
  final ClickKeyboardCallback finishedAction;

  ///标签
  TextEditingController _tagTextFieldVC = TextEditingController();
  FocusNode _tagFocusNode = new FocusNode();

  ///
  TagItemsWidget({
    Key key,
    this.list,
    this.placeholder,
    this.clickTagItemCallAction,
    this.finishedAction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> peopleLists = [];
    for (String name in list) {
      peopleLists.add(
          TagItemWidget(
            name: name,
            clickAction: clickTagItemCallAction,
          ));
    }
    peopleLists.add(TextField(
      controller: _tagTextFieldVC,
      focusNode: _tagFocusNode,
      enabled: true,
      minLines: 1,

      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: StringUtil.isEmpty(placeholder) ? "" : placeholder,
        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      ),
      onEditingComplete: () {
        String str = _tagTextFieldVC.text;
        if (str.length > 0) {
          finishedAction(_tagTextFieldVC.text);
          _tagTextFieldVC.text = "";
        } else {
          _tagFocusNode.unfocus();
        }
      },
    ));

    Widget content = Wrap(
        spacing: 8.0, // gap between adjacent chips
        runSpacing: 0.0, // gap between lines
        direction: Axis.horizontal, //方向
        children: peopleLists);
    return content;
  }
}

///单个标签🏷
class TagItemWidget extends StatelessWidget {
  final double size;
  final String name;
  final ClickTagItemCallback clickAction;

  TagItemWidget({
    Key key,
    this.size = 40,
    @required this.name,
    @required this.clickAction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return InputChip(
        clipBehavior: Clip.antiAlias,
        label: Text(name, style: TextStyle(fontSize: 16),),
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
          clickAction(name);
        },
        onPressed: () {
          clickAction(name);
        }
    );
  }
}