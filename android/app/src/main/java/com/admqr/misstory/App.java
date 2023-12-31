package com.admqr.misstory;

import android.util.Log;

import androidx.multidex.MultiDex;

import com.admqr.misstory.db.MyMigration;
import com.admqr.misstory.service.MainWorkService;
import com.admqr.misstory.utils.ApkHelper;
import com.admqr.misstory.utils.CrashHandler;
import com.tianyu704.daemon.ForegroundNotificationUtils;
import com.tianyu704.daemon.watch.WatchProcessPrefHelper;

import io.flutter.app.FlutterApplication;
import io.realm.Realm;
import io.realm.RealmConfiguration;

public class App extends FlutterApplication {

    @Override
    public void onCreate() {
        super.onCreate();
        createDataBase();
//        OkGo.getInstance().init(this).setRetryCount(1);
        MultiDex.install(this);
        //需要在 Application 的 onCreate() 中调用一次 DaemonEnv.initialize()
        // 每一次创建进程的时候都需要对Daemon环境进行初始化，所以这里没有判断进程
        String processName = ApkHelper.getProcessName(this.getApplicationContext());
        Log.d("wsh-daemon", "processName:" + processName);
        if (BuildConfig.APPLICATION_ID.equals(processName)) {
            // 主进程 进行一些其他的操作
            Log.d("wsh-daemon", "启动主进程");
        } else if ((BuildConfig.APPLICATION_ID + ":work").equals(processName)) {
            Log.d("wsh-daemon", "启动了工作进程");
        } else if ((BuildConfig.APPLICATION_ID + ":watch").equals(processName)) {
            // 这里要设置下看护进程所启动的主进程信息
            WatchProcessPrefHelper.mWorkServiceClass = MainWorkService.class;
            // 设置通知栏的UI
            ForegroundNotificationUtils.setResId(R.mipmap.ic_launcher);
            ForegroundNotificationUtils.setNotifyTitle("Misstory陪你走过每一天");
            ForegroundNotificationUtils.setNotifyContent("点击查看");
            ForegroundNotificationUtils.setPackgeName(BuildConfig.APPLICATION_ID);
            Log.d("wsh-daemon", "启动了看门狗进程");
        }
        CrashHandler.getInstance().init(this);
    }

    public void createDataBase() {
        Realm.init(this);
        RealmConfiguration config = new RealmConfiguration.Builder()
                .name("Misstory.realm")
                .schemaVersion(1)
                .migration(new MyMigration())
                .deleteRealmIfMigrationNeeded()
                .build();
        Realm.setDefaultConfiguration(config);
    }
}
