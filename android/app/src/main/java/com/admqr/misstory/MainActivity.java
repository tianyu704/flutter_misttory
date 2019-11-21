package com.admqr.misstory;

import android.Manifest;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.MainThread;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.admqr.misstory.db.LocationDataHelper;
import com.admqr.misstory.db.LocationHelper;
import com.admqr.misstory.eventbus.EventUtil;
import com.admqr.misstory.eventbus.LocationEvent;
import com.admqr.misstory.model.LocationData;
import com.admqr.misstory.model.MSLocation;
import com.admqr.misstory.service.MainWorkService;
import com.admqr.misstory.utils.JacksonUtil;
import com.admqr.misstory.utils.LocationUtil;
import com.admqr.misstory.utils.LogUtil;
import com.shihoo.daemon.DaemonEnv;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.List;
import java.util.UUID;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {
    static final String TAG = LogUtil.makeLogTag(MainActivity.class);
    //是否 任务完成, 不再需要服务运行? 最好使用SharePreference，注意要在同一进程中访问该属性
    public static boolean isCanStartWorkService;
    MethodChannel methodChannel;
    public static int PERMISSION_LOCATION = 100;
    public static int PERMISSION_STORAGE = 101;
    MethodChannel.Result result;
    LocationUtil locationUtil;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        methodChannel = new MethodChannel(getFlutterView(), "com.admqr.misstory");
        methodChannel.setMethodCallHandler(this);
        locationUtil = new LocationUtil(this);
    }


    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        this.result = result;
        if (methodCall.method.equals("start_location")) {
            int interval = methodCall.argument("interval");
            int distanceFilter = methodCall.argument("distanceFilter");
            if (interval != 0) {
                LocationUtil.interval = interval;
            }
            LocationUtil.distance = distanceFilter;
            LogUtil.d(TAG, interval + "-----" + distanceFilter);
            startLive();
        } else if (methodCall.method.equals("stop_location")) {
            stopLive();
        } else if (methodCall.method.equals("query_location_data")) {
            List<LocationData> locationList = LocationDataHelper.getInstance().getAllLocation();
            LocationDataHelper.getInstance().clearLocation();
            if (locationList != null && locationList.size() > 0) {
                result.success(JacksonUtil.getInstance().writeValueAsString(locationList));
            } else {
                result.success("");
            }
        } else if (methodCall.method.equals("current_location")) {
            onceLocation(result);
        } else if (methodCall.method.equals("query_location")) {
            List<MSLocation> locationList = LocationHelper.getInstance().getAllLocation();
            LocationHelper.getInstance().clearLocation();
            if (locationList != null && locationList.size() > 0) {
                result.success(JacksonUtil.getInstance().writeValueAsString(locationList));
            } else {
                result.success("");
            }
        } else if (methodCall.method.equals("request_location_permission")) {
            requestLocationPermission(result);
        } else if (methodCall.method.equals("request_storage_permission")) {
            requestStoragePermission(result);
        }
    }

    public void startLive() {
        DaemonEnv.sendStartWorkBroadcast(this);
        isCanStartWorkService = true;
        DaemonEnv.startServiceSafely(MainActivity.this, MainWorkService.class);
    }

    public void stopLive() {
        DaemonEnv.sendStopWorkBroadcast(this);
        isCanStartWorkService = false;
    }

    public void onceLocation(MethodChannel.Result result) {
        locationUtil.startOnce(location -> {
            result.success(JacksonUtil.getInstance().writeValueAsString(location));
        });
    }

//    //防止华为机型未加入白名单时按返回键回到桌面再锁屏后几秒钟进程被杀
//    public void onBackPressed() {
//        IntentWrapper.onBackPressed(this);
//    }

    private static final String CHANNEL_ID = "Misstory Service";
    private static final int CHANNEL_POSITION = 1;
    private int value;

    private void buildNotify(Context service) {
        NotificationManager manager = (NotificationManager) service.getSystemService(Context.NOTIFICATION_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "主服务",
                    NotificationManager.IMPORTANCE_DEFAULT);
            //是否绕过请勿打扰模式
            channel.canBypassDnd();
            //闪光灯
            channel.enableLights(true);
            //锁屏显示通知
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
            //闪关灯的灯光颜色
            channel.setLightColor(Color.RED);
            //桌面launcher的消息角标
            channel.canShowBadge();
            //是否允许震动
            channel.enableVibration(true);
            //获取系统通知响铃声音的配置
            channel.getAudioAttributes();
            //获取通知取到组
            channel.getGroup();
            //设置可绕过  请勿打扰模式
            channel.setBypassDnd(true);
            //设置震动模式
            channel.setVibrationPattern(new long[]{100, 100, 200});
            //是否会有灯光
            channel.shouldShowLights();
            manager.createNotificationChannel(channel);
            Notification notification = new Notification.Builder(service, CHANNEL_ID)
                    .setContentTitle("我是通知哦哦")//设置标题
                    .setContentText("我是通知内容..." + value)//设置内容
                    .setWhen(System.currentTimeMillis())//设置创建时间
                    .setSmallIcon(com.shihoo.daemon.R.drawable.icon1)//设置状态栏图标
                    .setLargeIcon(BitmapFactory.decodeResource(service.getResources(), com.shihoo.daemon.R.drawable.icon1))//设置通知栏图标
                    .build();
            manager.notify(CHANNEL_POSITION, notification);
        } else {
            Notification notification = new Notification.Builder(service)
                    .setContentTitle("我是通知哦哦")//设置标题
                    .setContentText("我是通知内容..." + value)//设置内容
                    .setWhen(System.currentTimeMillis())//设置创建时间
                    .setSmallIcon(com.shihoo.daemon.R.drawable.icon1)//设置状态栏图标
                    .setLargeIcon(BitmapFactory.decodeResource(service.getResources(), com.shihoo.daemon.R.drawable.icon1))//设置通知栏图标
                    .build();
            manager.notify(CHANNEL_POSITION, notification);
        }
    }

    //申请定位权限
    public void requestLocationPermission(MethodChannel.Result result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            result.success("GRANTED");
        } else {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION,
                            Manifest.permission.ACCESS_COARSE_LOCATION},
                    PERMISSION_LOCATION);
        }
    }

    //申请存储读写权限
    public void requestStoragePermission(MethodChannel.Result result) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
            result.success("GRANTED");
        } else {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE,
                            Manifest.permission.READ_EXTERNAL_STORAGE},
                    PERMISSION_STORAGE);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_LOCATION) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[1] == PackageManager.PERMISSION_GRANTED) {
                result.success("GRANTED");
            } else {
                result.success("DENIED");
                requestLocationPermission(result);
            }
        } else if (requestCode == PERMISSION_STORAGE) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED && grantResults[1] == PackageManager.PERMISSION_GRANTED) {
                result.success("GRANTED");
            } else {
                result.success("DENIED");
                requestStoragePermission(result);
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLocationEvent(LocationEvent event) {
        if (methodChannel != null) {
            String json = JacksonUtil.getInstance().writeValueAsString(event.locationData);
            methodChannel.invokeMethod("locationListener", json);
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        EventUtil.register(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        EventUtil.unregister(this);
    }
}
