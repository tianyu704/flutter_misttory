import 'package:flutter/material.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/models/tag.dart';

import '../db_manager.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-10
///
class TagHelper {
  static final TagHelper _instance = new TagHelper._internal();

  factory TagHelper() => _instance;

  TagHelper._internal();


  Tag createTagWithName(String name, num storyId) {
    Tag tag = Tag();
    tag.tagName = name;
    tag.storyId = storyId;
    return tag;
  }

  /// 创建Tag
  Future<bool> createTag(Tag tag) async {
    if (tag != null) {
      await FlutterOrmPlugin.saveOrm(DBManager.tableTag, tag.toJson());
      return true;
    }
    return false;
  }

  /// 删除某个tag
  Future<bool> deleteTag(Tag tag) async {
    if (tag != null) {
      await Query(DBManager.tableTag).primaryKey([tag.id]).delete();
      return true;
    }
    return false;
  }

  /// 根据storyId删除tag
  Future<bool> deleteTagsByStoryId(num storyId) async {
    await Query(DBManager.tableTag).whereByColumFilters([
      WhereCondiction("story_id", WhereCondictionType.IN, [storyId])
    ]).delete();
    return true;
  }

  /// 根据storyId查询tags
  Future<List<Tag>> queryTagsByStoryId(num storyId) async {
    List result = await Query(DBManager.tableTag).whereByColumFilters([
      WhereCondiction("story_id", WhereCondictionType.IN, [storyId])
    ]).all();
    if (result != null && result.length > 0) {
      List<Tag> list = [];
      result.forEach(
          (item) => list.add(Tag.fromJson(Map<String, dynamic>.from(item))));
      return list;
    }
    return null;
  }
}
