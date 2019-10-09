class DateUtil {
  static String getStayShowTime(num time) {
    int day = time ~/ (60 * 60 * 1000 * 24);
    int hour = (time - day * 24 * 60 * 60 * 1000) ~/ (60 * 60 * 1000);
    int min = (time ~/ (60 * 1000) - hour * 60 - day * 24 * 60).toInt();
    String dayStr = "";
    String hourStr = "";
    String minStr = "";
    if (day > 0) {
      dayStr = "${day}d";
    }
    if (hour > 0) {
      hourStr = "${hour}h";
    }
    if (min > 0) {
      minStr = "${min}min";
    }
    return "停留 $dayStr$hourStr$minStr";
  }
}
