// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misstory/db/helper/story_helper.dart';

import 'package:misstory/main.dart';
import 'package:misstory/models/story.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  test("testa", () async {
    print("===");
    print(await StoryHelper().getDistanceBetween1());
  });

  test("separate", () async{
    Story story = Story()
      ..createTime = 1570630867160
      ..updateTime = 1570668978351;

//    Story story = Story()
//      ..createTime = 1570758432968
//      ..updateTime = 1570759933269;
    List<Story> list =await StoryHelper().separateStory(story);
    list.forEach((item) {
      print(item.toJson());
    });
  });

  test("insert", () {
    List list = [1, 2, 3, 4];
    List list1 = [5, 6, 7, 8];
    list1.insertAll(0, list);
    print(list1);
  });

  test("map", () {
    Map<String, String> map = Map<String, String>();
    map["a"] = "1";
    map["b"] = "2";
    map["c"] = "3";
    map["d"] = "4";
    map["a"] = "5";
    print(map);
    HashMap hashMap;
  });

  test("null", () {
    var a;
    var b;
    print(a==b);
  });

  test("remove",(){
    List<String> a = ["a","b","c","d","e"];
    for(String item in a){
      if(item == "a"){
        a.remove(item);
      }
      if(item == "b"){
        a.remove(item);
      }
    }
    print(a);
  });
}
