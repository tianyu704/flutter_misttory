import 'package:flutter/material.dart';
import 'package:misstory/utils/string_util.dart';
import 'package:misstory/widgets/tag_item_widget.dart';

class TagItemsWidget extends StatelessWidget {
  final  List list;
  final  String placeholder;
  ///标签
  TextEditingController _tagTextFieldVC = TextEditingController();
  FocusNode _tagFocusNode = new FocusNode();
  ///
  TagItemsWidget({
    Key key,
    this.list,
    this.placeholder
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<Widget> peopleLists = [];
    for (String name in list) {
      peopleLists.add(TagItemWidget(name:name));
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
          list.add(str);
          _tagTextFieldVC.text = "";
//          setState(() {
//
//          });
        } else {
          _tagFocusNode.unfocus();
        }
      },
    ));

    Widget content = Wrap(
        spacing: 8.0, // gap between adjacent chips
        runSpacing: 4.0, // gap between lines
        direction: Axis.horizontal, //方向
        children: peopleLists);
    return content;
  }
}