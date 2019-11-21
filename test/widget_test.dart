// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:collection';
import 'dart:math';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:misstory/db/helper/story_helper.dart';

import 'package:misstory/main.dart';
import 'package:misstory/models/latlon_range.dart';
import 'package:misstory/models/latlonpoint.dart';
import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/picture.dart';
import 'package:misstory/models/story.dart';
import 'package:misstory/utils/calculate_util.dart';
import 'package:uuid/uuid.dart';

void main() {
//  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//    // Build our app and trigger a frame.
//    await tester.pumpWidget(MyApp());
//
//    // Verify that our counter starts at 0.
//    expect(find.text('0'), findsOneWidget);
//    expect(find.text('1'), findsNothing);
//
//    // Tap the '+' icon and trigger a frame.
//    await tester.tap(find.byIcon(Icons.add));
//    await tester.pump();
//
//    // Verify that our counter has incremented.
//    expect(find.text('0'), findsNothing);
//    expect(find.text('1'), findsOneWidget);
//  });

  test("testa", () async {
    print("===");
//    print(await StoryHelper().getDistanceBetween1());
  });

  test("separate", () async {
    Story story = Story()
      ..createTime = 1570630867160
      ..updateTime = 1570668978351;

//    Story story = Story()
//      ..createTime = 1570758432968
//      ..updateTime = 1570759933269;

//    List<Story> list = await StoryHelper().separateStory(story);
//    list.forEach((item) {
//      print(item.toJson());
//    });
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
    print(a == b);
  });

//  test("remove", () {
//    List<String> a = ["a", "b", "c", "d", "e"];
//    for (String item in a) {
//      if (item == "a") {
//        a.remove(item);
//      }
//      if (item == "b") {
//        a.remove(item);
//      }
//    }
//    print(a);
//  });
  test("aaaa", () async {
//    testa(0).then((v) {
//      print("11$v");
//    }, onError: (e) {
//      print("22$e");
//    });

    try {
      var a = await testa(0);
      print("11$a");
    } catch (e) {
      print("22$e");
    }
  });

  test("stringbuffer", () {
    String a = "1,2,3,4,5";
    List b = a.split(",");
    StringBuffer s = StringBuffer();
    print(s.toString());
    for (String i in b) {
      s.write(s.length == 0 ? i : ",$i");
    }
    print(a == s.toString());
  });

  test("modify", () {
    Picture p;
    Picture picture = Picture()
      ..id = "1"
      ..path = "1";
    p = picture;
    convert(picture);
    print(p.path);
  });

  test("distance", () async {
    Latlonpoint latLng1 = Latlonpoint(89.9990,180.000);
    Latlonpoint latLng2 = Latlonpoint(89.999, -90.0000);
    num m = DateTime.now().millisecondsSinceEpoch;
    num a = await CalculateUtil.calculateLineDistance(latLng1, latLng2);
//    num b =await CalculateUtil.calculateLineDistance(latLng1, latLng2);
//    num c =await CalculateUtil.calculateLineDistance(latLng1, latLng2);
//    num d =await CalculateUtil.calculateLineDistance(latLng1, latLng2);
    print(DateTime.now().millisecondsSinceEpoch - m);
    print(a);
    //85305.78125
  });

  test("aa", () {
    Mslocation mslocation = Mslocation();
    print(1 != mslocation.isFromPicture);
  });

  test("uuid", () {
    Uuid uuid = Uuid();
    print(uuid.v1());
    print(uuid.v1());
    print(uuid.v1());
    print(uuid.v4());
    print(uuid.v4());
    print(uuid.v4());
    print(uuid.v4());
  });
  
  test("range",()async{
    Latlonpoint latlonpoint = Latlonpoint(39.900155, 116.49277);
    latlonpoint.radius = 400;
    LatlonRange latlonRange = CalculateUtil.getRange(latlonpoint);
    print(latlonRange.toString());

    Latlonpoint latLng2 = Latlonpoint(39.89655787769784, 116.49745548670492);
    num a = await CalculateUtil.calculateLineDistance(latlonpoint, latLng2);
    print(a);
  });

  test("pase",()async{
    String a = '11.23332';
    print(double.tryParse(a));
  });
}

convert(Picture picture) {
  Picture p = picture;
  p.path = "2";
}

testb() {
  Future.delayed(Duration(seconds: 2)).then((v) {
//    testa(0).then((v){
//      return v;
//    },onError: (e){
//      return e;
//    });
    return testa(0);
  });
}

Future testa(var i) async {
  if (i == 0) {
    return throw (Exception(["aaaaaaa"]));
  }
  double n = 10 / 0;
  return n;
}
