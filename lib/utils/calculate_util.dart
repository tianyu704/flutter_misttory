import 'package:amap_base/amap_base.dart';
import 'package:misstory/models/coord_type.dart';
import 'package:misstory/models/latlonpoint.dart';
import 'dart:math';

import 'package:misstory/models/mslocation.dart';
import 'package:misstory/models/picture.dart';
import 'package:misstory/models/story.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-10
///
class CalculateUtil {
  static double calculateLatlngDistance(
      double lat1, double lng1, double lat2, double lng2) {
    return calculateLineDistance(
        Latlonpoint(lat1, lng1), Latlonpoint(lat2, lng2));
  }

  static Future<double> calculateStoriesDistance(Story l1, Story l2) async {
    if (l1 != null && l2 != null) {
      LatLng latLng1;
      if (l1.coordType == CoordType.gps) {
        latLng1 = await CalculateTools()
            .convertCoordinate(lat: l1.lat, lon: l1.lon, type: LatLngType.gps);
      } else {
        latLng1 = LatLng(l1.lat, l1.lon);
      }
      LatLng latLng2;
      if (l2.coordType == CoordType.gps) {
        latLng2 = await CalculateTools()
            .convertCoordinate(lat: l2.lat, lon: l2.lon, type: LatLngType.gps);
      } else {
        latLng2 = LatLng(l2.lat, l2.lon);
      }
      return calculateLineDistance(
          Latlonpoint(latLng1.latitude, latLng1.longitude),
          Latlonpoint(latLng2.latitude, latLng2.longitude));
    }
    return 1000000;
  }

  static Future<double> calculateStoryDistance(Story l1, Mslocation l2) async {
    if (l1 != null && l2 != null) {
      LatLng latLng1;
      if (l1.coordType == CoordType.gps) {
        latLng1 = await CalculateTools()
            .convertCoordinate(lat: l1.lat, lon: l1.lon, type: LatLngType.gps);
      } else {
        latLng1 = LatLng(l1.lat, l1.lon);
      }
      LatLng latLng2;
      if (l2.coordType == CoordType.gps) {
        latLng2 = await CalculateTools()
            .convertCoordinate(lat: l2.lat, lon: l2.lon, type: LatLngType.gps);
      } else {
        latLng2 = LatLng(l2.lat, l2.lon);
      }
      return calculateLineDistance(
          Latlonpoint(latLng1.latitude, latLng1.longitude),
          Latlonpoint(latLng2.latitude, latLng2.longitude));
    }
    return 1000000;
  }

  static Future<double> calculatePictureDistance(Story l1, Picture p) async {
    if (l1 != null && p != null) {
      LatLng latLng1;
      if (l1.coordType == CoordType.gps) {
        latLng1 = await CalculateTools()
            .convertCoordinate(lat: l1.lat, lon: l1.lon, type: LatLngType.gps);
      } else {
        latLng1 = LatLng(l1.lat, l1.lon);
      }
      LatLng latLng2 = await CalculateTools()
          .convertCoordinate(lat: p.lat, lon: p.lon, type: LatLngType.gps);
      return calculateLineDistance(
          Latlonpoint(latLng1.latitude, latLng1.longitude),
          Latlonpoint(latLng2.latitude, latLng2.longitude));
    }
    return 1000000;
  }

  static double calculateLineDistance(
      Latlonpoint latLng1, Latlonpoint latLng2) {
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
    if (points != null && points.length > 0) {
      //以下为简化方法（400km以内）
      int total = points.length;
      double lat = 0, lon = 0;
      for (Latlonpoint p in points) {
        lat += p.latitude * pi / 180;
        lon += p.longitude * pi / 180;
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
}
