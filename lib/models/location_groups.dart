import 'package:misstory/models/story.dart';
import 'package:misstory/db/helper/story_helper.dart';


class LocationGroupModel {
  DateTime dateTime;
  String showTime;
  List <Story> storysList = [];

}

/// 分组查询story
Future<List>findGroupStories() async {

  List list = await StoryHelper().findAllStories();
  var map = new Map();
  if (list.length > 0) {

    for (Story story in list) {
      DateTime time = DateTime.fromMicrosecondsSinceEpoch(story.createTime);
      String timeKey = "${time.year}${time.month}${time.day}";
      if (map.containsKey(timeKey)) {
        LocationGroupModel model = map[timeKey];
        model.storysList.add(story);
      } else {
        LocationGroupModel model = LocationGroupModel();
        model.dateTime = time;
        model.showTime = timeKey;
        model.storysList.add(story);
        map[timeKey] = model;
      }
    }
    for (LocationGroupModel group in map.values) {
         group.storysList.sort();
        // group.storysList.sort((left,right)=>right.createTime .compare(left.createTime));
    }

    return null;
  }
  return null;

}
