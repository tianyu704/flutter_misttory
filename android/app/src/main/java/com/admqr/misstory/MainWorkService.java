package com.admqr.misstory;

import android.content.ContentValues;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.location.Location;
import android.os.Handler;
import android.os.IBinder;
import android.os.Messenger;
import android.text.TextUtils;
import android.util.Log;

import com.admqr.misstory.db.LocationHelper;
import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.shihoo.daemon.work.AbsWorkService;

import java.io.File;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;
import me.yohom.amapbase.search.LatLng;


public class MainWorkService extends AbsWorkService {
    static final String Tag = "native db========>";
    private Disposable mDisposable;
    private long mSaveDataStamp;
    AMapLocationClient mLocationClient;

    /**
     * 是否 任务完成, 不再需要服务运行?
     *
     * @return 应当停止服务, true; 应当启动服务, false; 无法判断, 什么也不做, null.
     */
    @Override
    public Boolean needStartWorkService() {
        return MainActivity.isCanStartWorkService;
    }

    /**
     * 任务是否正在运行?
     *
     * @return 任务正在运行, true; 任务当前不在运行, false; 无法判断, 什么也不做, null.
     */
    @Override
    public Boolean isWorkRunning() {
        //若还没有取消订阅, 就说明任务仍在运行.
        return mDisposable != null && !mDisposable.isDisposed();
    }

    @Override
    public IBinder onBindService(Intent intent, Void v) {
        // 此处必须有返回，否则绑定无回调
        return new Messenger(new Handler()).getBinder();
    }

    @Override
    public void onServiceKilled() {
//        saveData();
        Log.d("wsh-daemon", "onServiceKilled --- 保存数据到磁盘");
    }

    @Override
    public void stopWork() {
        //取消对任务的订阅
        if (mDisposable != null && !mDisposable.isDisposed()) {
            mDisposable.dispose();
        }
//        saveData();
    }

    @Override
    public void startWork() {
        if (mLocationClient == null) {
            mLocationClient = new AMapLocationClient(this);
            //设置定位回调监听
            mLocationClient.setLocationListener(aMapLocation -> {
                //Log.d("android", aMapLocation.toStr());
                try {
//                    saveData(aMapLocation);
                    LocationHelper.getInstance().saveLocation(aMapLocation);
                } catch (Exception e) {
                    Log.d(Tag, e.getLocalizedMessage());
                }
            });
        }
        if (!mLocationClient.isStarted()) {
            AMapLocationClientOption option = new AMapLocationClientOption();
            option.setInterval(1000 * 60 * 3);
            option.setDeviceModeDistanceFilter(1000);
            option.setLocationMode(AMapLocationClientOption.AMapLocationMode.Battery_Saving);
            mLocationClient.setLocationOption(option);
            Observable.timer(30, TimeUnit.SECONDS).subscribe(new Consumer<Long>() {
                @Override
                public void accept(Long aLong) throws Exception {
                    mLocationClient.startLocation();
                }
            });
        }
//        Log.d("wsh-daemon", "检查磁盘中是否有上次销毁时保存的数据");
//        mDisposable = Observable
//                .interval(60, TimeUnit.SECONDS)
//                //取消任务时取消定时唤醒
//                .doOnDispose(new Action() {
//                    @Override
//                    public void run() throws Exception {
//                        Log.d("wsh-daemon", " -- doOnDispose ---  取消订阅 .... ");
//                        saveData();
//                    }
//                })
//                .subscribe(new Consumer<Long>() {
//                    @Override
//                    public void accept(Long aLong) throws Exception {
//                        Log.d("wsh-daemon", "每 60 秒采集一次数据... count = " + aLong);
////                        if (aLong > 0 && aLong % 18 == 0) {
//                        saveData();
//                        Log.d("wsh-daemon", "   采集数据  saveCount = " + (aLong - 1));
////                        }
//                        //Toast.makeText(MainWorkService.this, aLong + "", Toast.LENGTH_SHORT).show();
//                    }
//                });
    }


    private void saveData(AMapLocation location) {
        String path = getDir("data", MODE_PRIVATE).getAbsolutePath();
        File pathFile = new File(path);
        if (pathFile.exists()) {
            File file = new File(path + "/Misstory");
            SQLiteDatabase db = SQLiteDatabase.openOrCreateDatabase(file, null);
            db.enableWriteAheadLogging();
            if (db.isOpen()) {
                if (location != null && location.getErrorCode() == 0) {
                    MSLocation lastLocation = queryLastLocation(db);
                    if (lastLocation == null) {
                        createLocation(db, location);
//                        Log.d(Tag, "1111111111");
                    } else if (lastLocation.getLon() == location.getLongitude() &&
                            lastLocation.getLat() == location.getLatitude()) {
                        updateLocationTime(db, lastLocation.getId(), location);
                    } else {
                        if (TextUtils.equals(lastLocation.getAoiname(), location.getAoiName())) {
                            if (getDistanceBetween(location, lastLocation) >
                                    5000) {
                                createLocation(db, location);
//                                Log.d(Tag, "2222222222");
                            } else {
                                updateLocationTime(db, lastLocation.getId(), location);
                            }
                        } else if (TextUtils.equals(lastLocation.getPoiname(), location.getPoiName())) {
                            if (getDistanceBetween(location, lastLocation) >
                                    5000) {
                                createLocation(db, location);
//                                Log.d(Tag, "333333333333");
                            } else {
                                updateLocationTime(db, lastLocation.getId(), location);
                            }
                        } else {
                            createLocation(db, location);
//                            Log.d(Tag, "44444444444");
                        }
                    }
                }
            }
            db.close();
            Log.d(Tag, "save success!!!!!!");
        }
    }

    //更新时间
    public void updateLocationTime(SQLiteDatabase db, long id, AMapLocation aMapLocation) {
        String sql = "update MSLocation set updatetime = " + aMapLocation.getTime() + " where id = " + id;
        db.execSQL(sql);
        Log.d(Tag, "update success!!!!!!");
    }

    //查询最后一条Location
    public MSLocation queryLastLocation(SQLiteDatabase db) {
        Cursor cursor = db.query("MSLocation", null, null, null, null, null, "time");
        Log.d(Tag, cursor.getCount() + "");
        if (cursor.moveToLast()) {
            MSLocation location = new MSLocation();
//            cursor.move(cursor.getCount() - 1);
            long id = cursor.getInt(cursor.getColumnIndex("id"));
            double lon = cursor.getDouble(cursor.getColumnIndex("lon"));
            double lat = cursor.getDouble(cursor.getColumnIndex("lat"));
            String aoiname = cursor.getString(cursor.getColumnIndex("aoiname"));
            String poiname = cursor.getString(cursor.getColumnIndex("poiname"));
            location.setId(id);
            location.setLon(lon);
            location.setLat(lat);
            location.setAoiname(aoiname);
            location.setPoiname(poiname);
            Log.d(Tag, "id:" + id + ",lon:" + lon + ",lat:" + lat + ",aoiname:" + aoiname + ",poiname:" + poiname);
            return location;

        }
        return null;
    }


    //创建一条Location
    public void createLocation(SQLiteDatabase db, AMapLocation aMapLocation) {
        ContentValues contentValues = new ContentValues();
        contentValues.put("altitude", aMapLocation.getAltitude());
        contentValues.put("speed", aMapLocation.getSpeed());
        contentValues.put("bearing", aMapLocation.getBearing());
        contentValues.put("citycode", aMapLocation.getCityCode());
        contentValues.put("adcode", aMapLocation.getAdCode());
        contentValues.put("country", aMapLocation.getCountry());
        contentValues.put("province", aMapLocation.getProvince());
        contentValues.put("city", aMapLocation.getCity());
        contentValues.put("district", aMapLocation.getDistrict());
        contentValues.put("road", aMapLocation.getRoad());
        contentValues.put("street", aMapLocation.getStreet());
        contentValues.put("number", aMapLocation.getStreetNum());
        contentValues.put("poiname", aMapLocation.getPoiName());
        contentValues.put("errorCode", aMapLocation.getErrorCode());
        contentValues.put("errorInfo", aMapLocation.getErrorInfo());
        contentValues.put("locationType", aMapLocation.getLocationType());
        contentValues.put("locationDetail", aMapLocation.getLocationDetail());
        contentValues.put("aoiname", aMapLocation.getAoiName());
        contentValues.put("address", aMapLocation.getAddress());
        contentValues.put("poiid", aMapLocation.getBuildingId());
        contentValues.put("floor", aMapLocation.getFloor());
        contentValues.put("description", aMapLocation.getDescription());
        contentValues.put("time", aMapLocation.getTime());
        contentValues.put("updatetime", aMapLocation.getTime());
        contentValues.put("provider", aMapLocation.getProvider());
        contentValues.put("lon", aMapLocation.getLongitude());
        contentValues.put("lat", aMapLocation.getLatitude());
        contentValues.put("accuracy", aMapLocation.getAccuracy());
        contentValues.put("isOffset", aMapLocation.isOffset());
        contentValues.put("isFixLastLocation", aMapLocation.isFixLastLocation());
        contentValues.put("coordType", aMapLocation.getCoordType());
        contentValues.put("is_delete", false);
        db.insert("MSLocation", null, contentValues);
        Log.d(Tag, "create success!!!!!!");
    }

    //计算距离
    public float getDistanceBetween(AMapLocation location, MSLocation msLocation) {
        LatLng latLng1 = new LatLng(location.getLatitude(), location.getLongitude());
        LatLng latLng2 = new LatLng(msLocation.getLat(), msLocation.getLon());
        float distance = calculateLineDistance(latLng1, latLng2);
        Log.d(Tag, "distance is " + distance + " !!!!!!");
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
