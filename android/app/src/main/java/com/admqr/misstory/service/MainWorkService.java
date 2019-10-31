package com.admqr.misstory.service;

import android.content.ContentValues;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.Messenger;
import android.text.TextUtils;
import android.util.Log;

import com.admqr.misstory.MainActivity;
import com.admqr.misstory.db.LocationHelper;
import com.admqr.misstory.model.LocationResult;
import com.admqr.misstory.model.MSLocation;
import com.admqr.misstory.net.HttpRequest;
import com.admqr.misstory.utils.JacksonUtil;
import com.admqr.misstory.utils.LocationUtil;
import com.admqr.misstory.utils.LogUtil;
import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.lzy.okgo.callback.StringCallback;
import com.lzy.okgo.model.Response;
import com.shihoo.daemon.work.AbsWorkService;

import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;
import me.yohom.amapbase.search.LatLng;


public class MainWorkService extends AbsWorkService {
    static final String TAG = "native db========>";
    private Disposable mDisposable;
    private long mSaveDataStamp;
    AMapLocationClient mLocationClient;
    LocationUtil locationUtil;

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
        if (handler != null) {
            handler.removeMessages(1);
        }
    }

    @Override
    public void stopWork() {
        //取消对任务的订阅
        if (mDisposable != null && !mDisposable.isDisposed()) {
            mDisposable.dispose();
        }
        if (handler != null) {
            handler.removeMessages(1);
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

                    if (aMapLocation != null && aMapLocation.getErrorCode() == 0) {
                        HttpRequest.getInstance().cancel(HttpRequest.locationTag);
                        if ("GCJ02".equals(aMapLocation.getCoordType())) {
                            LocationHelper.getInstance().saveLocation(aMapLocation);
                        } else {
                            HttpRequest.getInstance().requestLocation(aMapLocation.getLatitude() + "," + aMapLocation.getLongitude(), new StringCallback() {
                                @Override
                                public void onSuccess(Response<String> response) {
                                    if (response != null && !TextUtils.isEmpty(response.body())) {
                                        LocationResult result = JacksonUtil.getInstance().readValue(response.body(), LocationResult.class);
                                        if (result != null && result.getMeta() != null
                                                && result.getMeta().getCode() == 200
                                                && result.getResponse() != null
                                                && result.getResponse().getVenues() != null
                                                && result.getResponse().getVenues().size() > 0) {
                                            LocationResult.ResponseBean.VenuesBean venuesBean = result.getResponse().getVenues().get(0);
                                            aMapLocation.setAoiName(venuesBean.getName());
                                            aMapLocation.setPoiName(venuesBean.getName());
                                            if (venuesBean.getLocation() != null) {
                                                LocationResult.ResponseBean.VenuesBean.LocationBean locationBean = venuesBean.getLocation();
                                                if (!TextUtils.isEmpty(locationBean.getCountry())) {
                                                    aMapLocation.setCountry(locationBean.getCountry());
                                                }
                                                if (!TextUtils.isEmpty(locationBean.getCity())) {
                                                    aMapLocation.setCity(locationBean.getCity());
                                                }
                                                if (!TextUtils.isEmpty(locationBean.getState())) {
                                                    aMapLocation.setProvince(locationBean.getState());
                                                }
                                                if (!TextUtils.isEmpty(locationBean.getAddress())) {
                                                    aMapLocation.setAddress(locationBean.getAddress());
                                                }
                                            }
                                            LogUtil.d(TAG,aMapLocation.toString());
                                            LocationHelper.getInstance().saveLocation(aMapLocation);
                                        }

                                    }
                                }
                            });
                        }
                    }
                } catch (Exception e) {
                    Log.d(TAG, e.getLocalizedMessage());
                }
            });
        }
        if (!mLocationClient.isStarted()) {
            AMapLocationClientOption option = new AMapLocationClientOption();
            option.setInterval(1000 * 60 * 3);
            option.setDeviceModeDistanceFilter(500);
            option.setMockEnable(true);
            option.setLocationMode(AMapLocationClientOption.AMapLocationMode.Battery_Saving);
            mLocationClient.setLocationOption(option);
            Observable.timer(30, TimeUnit.SECONDS).subscribe(new Consumer<Long>() {
                @Override
                public void accept(Long aLong) throws Exception {
                    mLocationClient.startLocation();
                }
            });
        }
//        if (locationUtil == null) {
//            locationUtil = new LocationUtil(MainWorkService.this);
//            locationUtil.setMsLocationListener(location -> {
//                Log.d(TAG, JacksonUtil.getInstance().writeValueAsString(location));
//            });
//            handler.sendEmptyMessageDelayed(1, 10 * 1000);
//        }

//        mDisposable = Observable
//                .interval(10, 60, TimeUnit.SECONDS)
//                //取消任务时取消定时唤醒
//                .doOnDispose(() -> {
//                    Log.d(TAG, " -- doOnDispose ---  取消订阅 .... ");
//                }).subscribeOn(Schedulers.io())
//                .subscribe(c -> {
//
//                });
    }

    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            Log.d(TAG, " -- 1分钟执行一次.... ");
            if (locationUtil.isStarted()) {
                locationUtil.stop();
            }
            locationUtil.start();
            handler.sendEmptyMessageDelayed(1, 60 * 1000);
        }
    };


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
        Log.d(TAG, "create success!!!!!!");
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
