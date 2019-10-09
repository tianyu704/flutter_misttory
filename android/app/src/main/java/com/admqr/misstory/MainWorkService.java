package com.admqr.misstory;

import android.content.ContentValues;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.os.Environment;
import android.os.Handler;
import android.os.IBinder;
import android.os.Messenger;
import android.util.Log;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.shihoo.daemon.work.AbsWorkService;

import java.io.File;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Action;
import io.reactivex.functions.Consumer;


public class MainWorkService extends AbsWorkService {

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
                Log.e("android", aMapLocation.toStr());
                saveData(aMapLocation);
            });
        }
        if (!mLocationClient.isStarted()) {
            AMapLocationClientOption option = new AMapLocationClientOption();
            option.setInterval(1000 * 60 * 5);
            option.setDeviceModeDistanceFilter(1000);
            option.setLocationMode(AMapLocationClientOption.AMapLocationMode.Battery_Saving);
            mLocationClient.setLocationOption(option);
            mLocationClient.startLocation();
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


    private void saveData(AMapLocation aMapLocation) {
        String path = getDir("data", MODE_PRIVATE).getAbsolutePath();
        File pathFile = new File(path);
        if (pathFile.exists()) {
            File file = new File(path + "/Misstory");
            SQLiteDatabase db = SQLiteDatabase.openOrCreateDatabase(file, null);
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
            contentValues.put("provider", aMapLocation.getProvider());
            contentValues.put("lon", aMapLocation.getLongitude());
            contentValues.put("lat", aMapLocation.getLatitude());
            contentValues.put("accuracy", aMapLocation.getAccuracy());
            contentValues.put("isOffset", aMapLocation.isOffset());
            contentValues.put("isFixLastLocation", aMapLocation.isFixLastLocation());
            contentValues.put("coordType", aMapLocation.getCoordType());
            contentValues.put("is_delete", false);
            db.insert("MSLocation", null, contentValues);
            db.close();
        }
    }

}
