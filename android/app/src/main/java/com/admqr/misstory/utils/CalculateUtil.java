//package com.admqr.misstory.utils;
//
//import android.content.ContentValues;
//import android.database.sqlite.SQLiteDatabase;
//import android.util.Log;
//
//import com.admqr.misstory.model.MSLocation;
//import com.amap.api.location.AMapLocation;
//
//import me.yohom.amapbase.search.LatLng;
//
///**
// * Created by hugo on 2019-11-19
// */
//public class CalculateUtil {
//    public static final String TAG = LogUtil.makeLogTag(CalculateUtil.class);
//
//    //计算距离
//    public float getDistanceBetween(AMapLocation location, MSLocation msLocation) {
//        LatLng latLng1 = new LatLng(location.getLatitude(), location.getLongitude());
//        LatLng latLng2 = new LatLng(msLocation.getLat(), msLocation.getLon());
//        float distance = calculateLineDistance(latLng1, latLng2);
//        Log.d(TAG, "distance is " + distance + " !!!!!!");
//        return distance;
//    }
//
//    //计算两点之间距离
//    public static float calculateLineDistance(LatLng var0, LatLng var1) {
//        if (var0 != null && var1 != null) {
//            try {
//                double var2 = var0.getLongitude();
//                double var4 = var0.getLatitude();
//                double var6 = var1.getLongitude();
//                double var8 = var1.getLatitude();
//                var2 *= 0.01745329251994329D;
//                var4 *= 0.01745329251994329D;
//                var6 *= 0.01745329251994329D;
//                var8 *= 0.01745329251994329D;
//                double var10 = Math.sin(var2);
//                double var12 = Math.sin(var4);
//                double var14 = Math.cos(var2);
//                double var16 = Math.cos(var4);
//                double var18 = Math.sin(var6);
//                double var20 = Math.sin(var8);
//                double var22 = Math.cos(var6);
//                double var24 = Math.cos(var8);
//                double[] var28 = new double[3];
//                double[] var29 = new double[3];
//                var28[0] = var16 * var14;
//                var28[1] = var16 * var10;
//                var28[2] = var12;
//                var29[0] = var24 * var22;
//                var29[1] = var24 * var18;
//                var29[2] = var20;
//                return (float) (Math.asin(Math.sqrt((var28[0] - var29[0]) * (var28[0] - var29[0]) + (var28[1] - var29[1]) * (var28[1] - var29[1]) + (var28[2] - var29[2]) * (var28[2] - var29[2])) / 2.0D) * 1.27420015798544E7D);
//            } catch (Throwable var26) {
//                var26.printStackTrace();
//                return 0.0F;
//            }
//        } else {
//            try {
//                throw new Exception("非法坐标值");
//            } catch (Exception var27) {
//                var27.printStackTrace();
//                return 0.0F;
//            }
//        }
//    }
//
//    //创建一条Location
//    public void createLocation(SQLiteDatabase db, AMapLocation aMapLocation) {
//        ContentValues contentValues = new ContentValues();
//        contentValues.put("altitude", aMapLocation.getAltitude());
//        contentValues.put("speed", aMapLocation.getSpeed());
//        contentValues.put("bearing", aMapLocation.getBearing());
//        contentValues.put("citycode", aMapLocation.getCityCode());
//        contentValues.put("adcode", aMapLocation.getAdCode());
//        contentValues.put("country", aMapLocation.getCountry());
//        contentValues.put("province", aMapLocation.getProvince());
//        contentValues.put("city", aMapLocation.getCity());
//        contentValues.put("district", aMapLocation.getDistrict());
//        contentValues.put("road", aMapLocation.getRoad());
//        contentValues.put("street", aMapLocation.getStreet());
//        contentValues.put("number", aMapLocation.getStreetNum());
//        contentValues.put("poiname", aMapLocation.getPoiName());
//        contentValues.put("errorCode", aMapLocation.getErrorCode());
//        contentValues.put("errorInfo", aMapLocation.getErrorInfo());
//        contentValues.put("locationType", aMapLocation.getLocationType());
//        contentValues.put("locationDetail", aMapLocation.getLocationDetail());
//        contentValues.put("aoiname", aMapLocation.getAoiName());
//        contentValues.put("address", aMapLocation.getAddress());
//        contentValues.put("poiid", aMapLocation.getBuildingId());
//        contentValues.put("floor", aMapLocation.getFloor());
//        contentValues.put("description", aMapLocation.getDescription());
//        contentValues.put("time", aMapLocation.getTime());
//        contentValues.put("updatetime", aMapLocation.getTime());
//        contentValues.put("provider", aMapLocation.getProvider());
//        contentValues.put("lon", aMapLocation.getLongitude());
//        contentValues.put("lat", aMapLocation.getLatitude());
//        contentValues.put("accuracy", aMapLocation.getAccuracy());
//        contentValues.put("isOffset", aMapLocation.isOffset());
//        contentValues.put("isFixLastLocation", aMapLocation.isFixLastLocation());
//        contentValues.put("coordType", aMapLocation.getCoordType());
//        contentValues.put("is_delete", false);
//        db.insert("MSLocation", null, contentValues);
//        Log.d(TAG, "create success!!!!!!");
//    }
//}
