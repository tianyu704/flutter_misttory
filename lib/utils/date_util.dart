import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:misstory/generated/i18n.dart';

class DateUtil {
  static String getStayShowTime(num time) {
    if (time < 1000 * 60) {
      return "<1min";
    }
    int day = time ~/ (60 * 60 * 1000 * 24);
    int hour = (time - day * 24 * 60 * 60 * 1000) ~/ (60 * 60 * 1000);
    int min = (time ~/ (60 * 1000) - hour * 60 - day * 24 * 60).toInt();
    String dayStr = "";
    String hourStr = "";
    String minStr = "";
    if (day > 0) {
      dayStr = "${day}d ";
    }
    if (hour > 0) {
      hourStr = "${hour}h ";
    }
    if (min > 0) {
      minStr = "${min}min";
    }
    return "$dayStr$hourStr$minStr";
  }

  /// 2019.7.12转换成7月12日星期三
  static String getMonthDayWeek(BuildContext context, String date) {
    if (date != null && date.isEmpty) {
      return "";
    }
    List<String> dateList = date.split(".");
    DateTime dateTime = DateTime(
        int.parse(dateList[0]), int.parse(dateList[1]), int.parse(dateList[2]));
    List<String> weekList = getWeekList(context);
    DateTime current = DateTime.now();
    if (dateTime.year == current.year) {
      return "${dateTime.month}月${dateTime.day}日 ${weekList[dateTime.weekday - 1]}";
    } else {
      return "${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${weekList[dateTime.weekday - 1]}";
    }
  }

  static List<String> getWeekList(BuildContext context) {
    return [
      S.of(context).monday,
      S.of(context).tuesday,
      S.of(context).wednesday,
      S.of(context).thursday,
      S.of(context).friday,
      S.of(context).saturday,
      S.of(context).sunday,
    ];
  }

  ///判断是否为同一天
  static bool isSameDay(num millis1, num millis2) {
    if (millis1 != null && millis2 != null) {
      DateTime d1 = DateTime.fromMillisecondsSinceEpoch(millis1.toInt());
      DateTime d2 = DateTime.fromMillisecondsSinceEpoch(millis2.toInt());
      if (d1.year == d2.year && d1.month == d2.month && d1.day == d2.day) {
        return true;
      }
    }
    return false;
  }

  /// 时间戳转换成 10月10日 17：45
  static String getMonthDayHourMin(num millis) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis.toInt());
    return DateFormat("M月d日 HH:mm").format(dateTime);
  }

  ///获取展示的时间 2019.09.23
  static String getShowTime(num timeStr) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timeStr.toInt());
    String newTime = DateFormat("yyyy.MM.dd").format(time);
    return newTime;
  }
}
