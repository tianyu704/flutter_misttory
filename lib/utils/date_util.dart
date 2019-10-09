

class DateUtil {

  static String getStayShowTime(num time) {
    int hour = time  ~/ (60 * 60 * 1000);
    int min = (time ~/ (60 * 1000) - hour * 60).toInt();
    String hourStr = "";
    String minStr = "";
    if (hour > 0) {
        hourStr = "$hour h";
    }
    if (min > 0) {
        minStr = "$min min";
    }
    return "停留 $hourStr$minStr";
  }

}
