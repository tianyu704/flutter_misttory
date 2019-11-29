import 'package:misstory/models/latlon_range.dart';
import 'package:misstory/models/latlonpoint.dart';
import 'dart:math';

///
/// Create by Hugo.Guo
/// Date: 2019-10-10
///
class CalculateUtil {
  static final num PI = 3.14159265358979324;
  static final num x_pi = 3.14159265358979324 * 3000.0 / 180.0;

  static double calculateLatlngDistance(
      double lat1, double lng1, double lat2, double lng2) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
      return double.infinity;
    }
    return calculateLineDistance(
        Latlonpoint(lat1, lng1), Latlonpoint(lat2, lng2));
  }

  static double calculateLineDistance(
      Latlonpoint latLng1, Latlonpoint latLng2) {
    if (latLng1 != null && latLng2 != null) {
      try {
        double var2 = latLng1.lon;
        double var4 = latLng1.lat;
        double var6 = latLng2.lon;
        double var8 = latLng2.lat;
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
        List<double> var28 = [0.0, 0.0, 0.0];
        List<double> var29 = [0.0, 0.0, 0.0];
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

  static Future<Latlonpoint> calculateCenterLatLon(
      List<Latlonpoint> points) async {
    if (points != null && points.length == 1) {
      return points[0]..radius = 0;
    }
    if (points != null && points.length > 0) {
      //以下为简化方法（400km以内）
      int total = points.length;
      double lat = 0, lon = 0;
      for (Latlonpoint p in points) {
        lat += p.lat * pi / 180;
        lon += p.lon * pi / 180;
      }
      lat /= total;
      lon /= total;
      Latlonpoint latlonpoint = Latlonpoint(lat * 180 / pi, lon * 180 / pi);
      num radius = 0;
      for (Latlonpoint p in points) {
        radius += calculateLineDistance(p, latlonpoint);
      }
      latlonpoint.radius = radius / total;
      return latlonpoint;
    }
    return null;
  }

  static LatlonRange getRange(Latlonpoint latlon) {
    if (latlon != null) {
      LatlonRange latlonRange = LatlonRange();
      num latR = latlon.radius / 111.2 * 0.001;
      num lonR = latlon.radius / 85.37 * 0.001;
      latlonRange.minLat = latlon.lat - latR;
      latlonRange.maxLat = latlon.lat + latR;
      latlonRange.minLon = latlon.lon - lonR;
      latlonRange.maxLon = latlon.lon + lonR;
      if (latlonRange.minLat < -90) {
        latlonRange.minLat = -90.000000;
      }
      if (latlonRange.maxLat > 90) {
        latlonRange.maxLat = 90.000000;
      }
      if (latlonRange.minLon < -180) {
        latlonRange.minLon = -180.000000;
      }
      if (latlonRange.maxLon > 180) {
        latlonRange.maxLon = 180.000000;
      }
      return latlonRange;
    }
    return null;
  }

  //GCJ-02 to WGS-84 exactly
  static gcjToWgs(gcjLat, gcjLon) {
    var initDelta = 0.01;
    var threshold = 0.000000001;
    var dLat = initDelta, dLon = initDelta;
    var mLat = gcjLat - dLat, mLon = gcjLon - dLon;
    var pLat = gcjLat + dLat, pLon = gcjLon + dLon;
    var wgsLat, wgsLon, i = 0;
    while (true) {
      wgsLat = (mLat + pLat) / 2;
      wgsLon = (mLon + pLon) / 2;
      var tmp = wgsToGcj(wgsLat, wgsLon);
      dLat = tmp['lat'] - gcjLat;
      dLon = tmp['lon'] - gcjLon;
      if ((dLat.abs() < threshold) && (dLon.abs() < threshold)) break;

      if (dLat > 0)
        pLat = wgsLat;
      else
        mLat = wgsLat;
      if (dLon > 0)
        pLon = wgsLon;
      else
        mLon = wgsLon;

      if (++i > 10000) break;
    }
//    print(i);
    return {'lat': wgsLat, 'lon': wgsLon};
  }

//WGS-84 to GCJ-02
  static wgsToGcj(wgsLat, wgsLon) {
    if (outOfChina(wgsLat, wgsLon)) return {'lat': wgsLat, 'lon': wgsLon};
    var d = _delta(wgsLat, wgsLon);
    return {'lat': wgsLat + d['lat'], 'lon': wgsLon + d['lon']};
  }

  static _delta(lat, lon) {
    // Krasovsky 1940
    //
    // a = 6378245.0, 1/f = 298.3
    // b = a * (1 - f)
    // ee = (a^2 - b^2) / a^2;
    var a = 6378245.0; //  a: 卫星椭球坐标投影到平面地图坐标系的投影因子。
    var ee = 0.00669342162296594323; //  ee: 椭球的偏心率。
    var dLat = _transformLat(lon - 105.0, lat - 35.0);
    var dLon = _transformLon(lon - 105.0, lat - 35.0);
    var radLat = lat / 180.0 * PI;
    var magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    var sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * PI);
    return {'lat': dLat, 'lon': dLon};
  }

  static outOfChina(lat, lon) {
    if (lon < 72.004 || lon > 137.8347) return true;
    if (lat < 0.8293 || lat > 55.8271) return true;
    return false;
  }

  static _transformLat(num x, num y) {
    var ret = -100.0 +
        2.0 * x +
        3.0 * y +
        0.2 * y * y +
        0.1 * x * y +
        0.2 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * PI) + 20.0 * sin(2.0 * x * PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * PI) + 40.0 * sin(y / 3.0 * PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * PI) + 320 * sin(y * PI / 30.0)) * 2.0 / 3.0;
    return ret;
  }

  static _transformLon(num x, num y) {
    var ret =
        300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * PI) + 20.0 * sin(2.0 * x * PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * PI) + 40.0 * sin(x / 3.0 * PI)) * 2.0 / 3.0;
    ret +=
        (150.0 * sin(x / 12.0 * PI) + 300.0 * sin(x / 30.0 * PI)) * 2.0 / 3.0;
    return ret;
  }

  // two point's distance
  static distance(latA, lonA, latB, lonB) {
    var earthR = 6371000.0;
    var x = cos(latA * PI / 180.0) *
        cos(latB * PI / 180.0) *
        cos((lonA - lonB) * PI / 180);
    var y = sin(latA * PI / 180.0) * sin(latB * PI / 180.0);
    var s = x + y;
    if (s > 1) s = 1;
    if (s < -1) s = -1;
    var alpha = acos(s);
    var distance = alpha * earthR;
    return distance;
  }

  //GCJ-02 to BD-09
  static gcjToBd(gcjLat, gcjLon) {
    var x = gcjLon, y = gcjLat;
    var z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    var theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    var bdLon = z * cos(theta) + 0.0065;
    var bdLat = z * sin(theta) + 0.006;
    return {'lat': bdLat, 'lon': bdLon};
  }

  //BD-09 to GCJ-02
  static bdToGcj(bdLat, bdLon) {
    var x = bdLon - 0.0065, y = bdLat - 0.006;
    var z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    var theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    var gcjLon = z * cos(theta);
    var gcjLat = z * sin(theta);
    return {'lat': gcjLat, 'lon': gcjLon};
  }
}
