import 'package:flutter/material.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-09-29
///
class StoryHelper{
  final String tableName = "Story";
  final String columnId = "id";
  final String columnTime = "time";

  static final StoryHelper _instance = new StoryHelper._internal();

  factory StoryHelper() => _instance;

  StoryHelper._internal();
}