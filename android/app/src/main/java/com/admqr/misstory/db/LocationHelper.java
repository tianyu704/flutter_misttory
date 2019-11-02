package com.admqr.misstory.db;

import android.text.TextUtils;
import android.util.Log;

import com.admqr.misstory.model.MSLocation;
import com.amap.api.location.AMapLocation;

import java.util.List;

import io.realm.Realm;
import io.realm.RealmResults;
import io.realm.Sort;
import me.yohom.amapbase.search.LatLng;

/**
 * Created by hugo on 2019-10-16
 */
public class LocationHelper {
    private static final String TAG = "LocationHelper";

    private static class Holder {
        private final static LocationHelper instance = new LocationHelper();
    }

    public static LocationHelper getInstance() {
        return Holder.instance;
    }

    //查询所有Location
    public List<MSLocation> getAllLocation() {
        Realm realm = Realm.getDefaultInstance();//获取Realm实例
        try {
            RealmResults<MSLocation> results = realm.where(MSLocation.class).findAll();
            List<MSLocation> locations = realm.copyFromRealm(results);
            return locations;
        } finally {
            realm.close();
        }
    }

    //清除所有Location
    public void clearLocation() {
        Realm mRealm = Realm.getDefaultInstance();//获取Realm实例
        mRealm.executeTransaction(realm -> {
            realm.delete(MSLocation.class);
        });
    }

    public void saveLocation(AMapLocation location) {
        if (location != null && location.getErrorCode() == 0) {
            MSLocation lastLocation = queryLastLocation();
            if (lastLocation == null) {
                createLocation(location);
//                        Log.d(Tag, "1111111111");
            } else if (lastLocation.getLon() == location.getLongitude() &&
                    lastLocation.getLat() == location.getLatitude()) {
                updateLocationTime(lastLocation.getId(), location);
            } else {
                if (TextUtils.equals(lastLocation.getAoiname(), location.getAoiName())) {
                    if (getDistanceBetween(location, lastLocation) >
                            5000) {
                        createLocation(location);
//                                Log.d(Tag, "2222222222");
                    } else {
                        updateLocationTime(lastLocation.getId(), location);
                    }
                } else if (TextUtils.equals(lastLocation.getPoiname(), location.getPoiName())) {
                    if (getDistanceBetween(location, lastLocation) >
                            5000) {
                        createLocation(location);
//                                Log.d(Tag, "333333333333");
                    } else {
                        updateLocationTime(lastLocation.getId(), location);
                    }
                } else {
                    createLocation(location);
//                            Log.d(Tag, "44444444444");
                }
            }
        }
    }

    //更新时间
    public void updateLocationTime(long id, AMapLocation aMapLocation) {
        Realm realm = Realm.getDefaultInstance();
        try {
            realm.executeTransaction(realm1 -> {
                MSLocation location = realm1.where(MSLocation.class).equalTo("id", id).findFirst();
                location.setUpdatetime(aMapLocation.getTime());
            });
        } finally {
            realm.close();
        }
        Log.d(TAG, "update success!!!!!!");
    }


    //创建一条Location
    public void createLocation(AMapLocation aMapLocation) {
        MSLocation location = convertAMapLocation(aMapLocation);
        if (location != null) {
            Realm realm = Realm.getDefaultInstance();
            try {
                realm.beginTransaction();
                realm.copyToRealmOrUpdate(location);
                realm.commitTransaction();
            } finally {
                realm.close();
            }
            Log.d(TAG, "create success!!!!!!");
        }
    }

    //查询最后一条Location
    public MSLocation queryLastLocation() {
        Realm realm = Realm.getDefaultInstance();
        try {
            MSLocation location = realm.where(MSLocation.class).sort("time", Sort.DESCENDING).findFirst();
            if (location == null) {
                return null;
            }
            MSLocation msLocation = realm.copyFromRealm(location);
            return msLocation;
        } finally {
            realm.close();
        }
    }

    public MSLocation convertAMapLocation(AMapLocation aMapLocation) {
        if (aMapLocation == null) {
            return null;
        }
        MSLocation location = new MSLocation();
        location.setAltitude(aMapLocation.getAltitude());
        location.setUpdatetime(aMapLocation.getTime());
        location.setPoiname(aMapLocation.getPoiName());
        location.setAoiname(aMapLocation.getAoiName());
        location.setLat(aMapLocation.getLatitude());
        location.setLon(aMapLocation.getLongitude());
        location.setAccuracy(aMapLocation.getAccuracy());
        location.setAdcode(aMapLocation.getAdCode());
        location.setAddress(aMapLocation.getAddress());
        location.setBearing(aMapLocation.getBearing());
        location.setCity(aMapLocation.getCity());
        location.setCitycode(aMapLocation.getCityCode());
        location.setCoordType(aMapLocation.getCoordType());
        location.setCountry(aMapLocation.getCountry());
        location.setDescription(aMapLocation.getDescription());
        location.setDistrict(aMapLocation.getDistrict());
        location.setErrorCode(aMapLocation.getErrorCode());
        location.setErrorInfo(aMapLocation.getErrorInfo());
        location.setFixLastLocation(aMapLocation.isFixLastLocation());
        location.setFloor(aMapLocation.getFloor());
        location.setIs_delete(false);
        location.setLocationDetail(aMapLocation.getLocationDetail());
        location.setLocationType(aMapLocation.getLocationType());
        location.setNumber(aMapLocation.getStreetNum());
        location.setOffset(aMapLocation.isOffset());
        location.setPoiid(aMapLocation.getBuildingId());
        location.setProvider(aMapLocation.getProvider());
        location.setProvince(aMapLocation.getProvince());
        location.setRoad(aMapLocation.getRoad());
        location.setSpeed(aMapLocation.getSpeed());
        location.setStreet(aMapLocation.getStreet());
        location.setTime(aMapLocation.getTime());
        return location;
    }

    //计算距离
    public float getDistanceBetween(AMapLocation location, MSLocation msLocation) {
        LatLng latLng1 = new LatLng(location.getLatitude(), location.getLongitude());
        LatLng latLng2 = new LatLng(msLocation.getLat(), msLocation.getLon());
        float distance = calculateLineDistance(latLng1, latLng2);
        Log.d(TAG, "distance is " + distance + " !!!!!!");
        return distance;
    }

    //计算两点之间距离
    public static float calculateLineDistance(LatLng var0, LatLng var1) {
        if (var0 != null && var1 != null) {
            try {
                double var2 = var0.getLongitude();
                double var4 = var0.getLatitude();
                double var6 = var1.getLongitude();
                double var8 = var1.getLatitude();
                var2 *= 0.01745329251994329D;
                var4 *= 0.01745329251994329D;
                var6 *= 0.01745329251994329D;
                var8 *= 0.01745329251994329D;
                double var10 = Math.sin(var2);
                double var12 = Math.sin(var4);
                double var14 = Math.cos(var2);
                double var16 = Math.cos(var4);
                double var18 = Math.sin(var6);
                double var20 = Math.sin(var8);
                double var22 = Math.cos(var6);
                double var24 = Math.cos(var8);
                double[] var28 = new double[3];
                double[] var29 = new double[3];
                var28[0] = var16 * var14;
                var28[1] = var16 * var10;
                var28[2] = var12;
                var29[0] = var24 * var22;
                var29[1] = var24 * var18;
                var29[2] = var20;
                return (float) (Math.asin(Math.sqrt((var28[0] - var29[0]) * (var28[0] - var29[0]) + (var28[1] - var29[1]) * (var28[1] - var29[1]) + (var28[2] - var29[2]) * (var28[2] - var29[2])) / 2.0D) * 1.27420015798544E7D);
            } catch (Throwable var26) {
                var26.printStackTrace();
                return 0.0F;
            }
        } else {
            try {
                throw new Exception("非法坐标值");
            } catch (Exception var27) {
                var27.printStackTrace();
                return 0.0F;
            }
        }
    }
}
