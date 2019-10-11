import 'package:flutter/material.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/models/person.dart';
import 'package:misstory/models/tag.dart';

import '../db_manager.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-10
///
class PersonHelper {
  static final PersonHelper _instance = new PersonHelper._internal();

  factory PersonHelper() => _instance;

  PersonHelper._internal();

  Person createPersonWithName(String name, num storyId) {
    Person person = Person();
    person.name = name;
    person.storyId = storyId;
    print("json ：${person.toJson()}");
    return person;
  }

  /// 创建Person
  Future<bool> createPerson(Person person) async {
    if (person != null) {
      await FlutterOrmPlugin.saveOrm(DBManager.tablePerson, person.toJson());
      print("xsave ${person.storyId}");
      return true;
    }
    return false;
  }

  /// 删除某个Person
  Future<bool> deletePerson(Person person) async {
    if (person != null) {
      await Query(DBManager.tablePerson).primaryKey([person.id]).delete();
      return true;
    }
    return false;
  }

  /// 根据storyId删除person
  Future<bool> deletePersonsByStoryId(num storyId) async {
    await Query(DBManager.tablePerson).whereByColumFilters([
      WhereCondiction("story_id", WhereCondictionType.IN, [storyId])
    ]).delete();
    return true;
  }

  /// 根据storyId查询persons
  Future<List<Person>> queryPersonsByStoryId(num storyId) async {
    List result = await Query(DBManager.tablePerson).whereByColumFilters([
      WhereCondiction("story_id", WhereCondictionType.IN, [storyId])
    ]).all();
    if (result != null && result.length > 0) {
      List<Person> list = [];
      result.forEach(
          (item) => list.add(Person.fromJson(Map<String, dynamic>.from(item))));
      return list;
    }
    return null;
  }
}
