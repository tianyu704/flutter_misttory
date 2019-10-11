import 'package:amap_base/amap_base.dart';
import 'dart:math';

///
/// Create by Hugo.Guo
/// Date: 2019-10-10
///
class CalculateUtil {
  static Future<num> calculateLineDistance(
      LatLng latLng1, LatLng latLng2) async {
    if (latLng1 != null && latLng2 != null) {
      try {
        double var2 = latLng1.longitude;
        double var4 = latLng1.latitude;
        double var6 = latLng2.longitude;
        double var8 = latLng2.latitude;
        var2 *= 0.01745329251994329;
        var4 *= 0.01745329251994329;
        var6 *= 0.01745329251994329;
        var8 *= 0.01745329251994329;
        double var10 = sin(var2);
        double var12 = sin(var4);
        double var14 = cos(var2);
        double var16 = cos(var4);
        double var18 = sin(var6);
        double var20 = sin(var8);
        double var22 = cos(var6);
        double var24 = cos(var8);
        List<double> var28 = [0.0,0.0,0.0];
        List<double> var29 = [0.0,0.0,0.0];
        var28[0] = var16 * var14;
        var28[1] = var16 * var10;
        var28[2] = var12;
        var29[0] = var24 * var22;
        var29[1] = var24 * var18;
        var29[2] = var20;
        return asin(sqrt((var28[0] - var29[0]) * (var28[0] - var29[0]) +
                    (var28[1] - var29[1]) * (var28[1] - var29[1]) +
                    (var28[2] - var29[2]) * (var28[2] - var29[2])) /
                2.0) *
            1.27420015798544E7;
      } catch (e) {
        print("#1 $e");
        return 0.0;
      }
    } else {
      try {
        throw new Exception("非法坐标值");
      } catch (e) {
        print("#2 $e");
        return 0.0;
      }
    }
  }
}
