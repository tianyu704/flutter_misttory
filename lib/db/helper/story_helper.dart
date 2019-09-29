import 'package:flutter/material.dart';
import 'package:flutter_orm_plugin/flutter_orm_plugin.dart';
import 'package:misstory/models/story.dart';

import '../db_manager.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-09-29
///
class StoryHelper {
  final String tableName = "Story";
  final String columnId = "id";
  final String columnTime = "time";

  static final StoryHelper _instance = new StoryHelper._internal();

  factory StoryHelper() => _instance;

  StoryHelper._internal();

  /// 创建story
  Future createStory(Story story) async {
    if (story != null) {
      await FlutterOrmPlugin.saveOrm(DBManager.tableStory, story.toJson());
    }
  }

  /// 更新story时间
  Future updateStoryTime(num storyId, num time) async {
    await Query(DBManager.tableStory)
        .primaryKey([storyId]).update({"update_time": time});
  }
}
