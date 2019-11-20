package com.admqr.misstory.service;

import android.content.ContentValues;
import android.content.Intent;
import android.database.sqlite.SQLiteDatabase;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.Messenger;
import android.text.TextUtils;
import android.util.Log;

import com.admqr.misstory.MainActivity;
import com.admqr.misstory.db.LocationDataHelper;
import com.admqr.misstory.db.LocationHelper;
import com.admqr.misstory.eventbus.EventUtil;
import com.admqr.misstory.model.LocationData;
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

import java.util.UUID;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.disposables.Disposable;
import io.reactivex.functions.Consumer;
import me.yohom.amapbase.search.LatLng;


public class MainWorkService extends AbsWorkService {
    static final String TAG = LogUtil.makeLogTag(MainWorkService.class);
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
            handler.removeMessages(0);
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
            handler.removeMessages(0);
        }
//        saveData();
    }

    @Override
    public void startWork() {
//        initAMap();
        initNative();
    }

    public void initNative() {
        if (locationUtil == null) {
            locationUtil = new LocationUtil(MainWorkService.this);
            locationUtil.setMsLocationListener(locationData -> {
//                Log.d(TAG, JacksonUtil.getInstance().writeValueAsString(location));
                LocationDataHelper.getInstance().createLocation(locationData);
                EventUtil.postLocationEvent(locationData);
            });
            handler.removeMessages(1);
            handler.sendEmptyMessageDelayed(1, 10 * 1000);
        }
    }

    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
//            Log.d(TAG, msg.what + "==" + mLocationClient.isStarted());
            if (msg.what == 0 && mLocationClient != null) {
                mLocationClient.stopLocation();
                AMapLocationClientOption option = new AMapLocationClientOption();
//                    option.setInterval(1000 * 60 * 3);
                option.setDeviceModeDistanceFilter(100);
                option.setMockEnable(false);
                option.setOnceLocation(true);
                option.setOnceLocationLatest(true);
//            option.setGeoLanguage(AMapLocationClientOption.GeoLanguage.EN);
                option.setLocationMode(AMapLocationClientOption.AMapLocationMode.Battery_Saving);
                mLocationClient.setLocationOption(option);
                mLocationClient.startLocation();
//                    Observable.timer(30, TimeUnit.SECONDS).subscribe(new Consumer<Long>() {
//                        @Override
//                        public void accept(Long aLong) throws Exception {
//                            mLocationClient.startLocation();
//                        }
//                    });
                handler.sendEmptyMessageDelayed(0, LocationUtil.interval);
            } else if (msg.what == 1) {
                Log.d(TAG, LocationUtil.interval / 60 / 1000 + " 分钟执行一次.... ");
                if (locationUtil.isStarted()) {
                    locationUtil.stop();
                }
                locationUtil.start();
                handler.sendEmptyMessageDelayed(1, LocationUtil.interval);
            }

        }
    };

    public void initAMap() {
        if (mLocationClient == null) {
            mLocationClient = new AMapLocationClient(this);
            //设置定位回调监听
            mLocationClient.setLocationListener(aMapLocation -> {
                mLocationClient.stopLocation();
                Log.d(TAG, aMapLocation.getLocationType() + ":" + aMapLocation.getLatitude() + "," + aMapLocation.getLongitude());
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
                                            LogUtil.d(TAG, aMapLocation.toString());
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
        if (mLocationClient != null) {
            handler.removeMessages(0);
            handler.sendEmptyMessageDelayed(0, 30 * 1000);
        }
    }

}
