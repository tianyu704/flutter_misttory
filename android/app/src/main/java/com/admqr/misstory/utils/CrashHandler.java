package com.admqr.misstory.utils;

import android.os.Environment;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class CrashHandler implements Thread.UncaughtExceptionHandler {

    public static CrashHandler instance;

    private CrashHandler() {
    }

    public static CrashHandler get_instance() {
        if (instance == null)
            instance = new CrashHandler();
        return instance;
    }

    public void init() {
        Thread.setDefaultUncaughtExceptionHandler(this);
    }

    @Override
    public void uncaughtException(Thread thread, Throwable ex) {
        saveFile(ex.getMessage(), "crash.txt");
        //退出程序
        //这里由于是我们自己处理的异常，必须手动退出程序，不然系统出一只处于crash等待状态
        android.os.Process.killProcess(android.os.Process.myPid());
        LogUtil.e("CrashHandler",ex.getMessage());
        System.exit(1);
    }

    public static void saveFile(String data, String file_name) {
        File sdPath = new File(Environment.getExternalStorageDirectory().getAbsolutePath()
                + File.separator + "MisstoryCrash" + File.separator + "cache");
        if (!sdPath.exists()) {
            sdPath.mkdirs();
        }
        File file = new File(sdPath, file_name);
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(file);
            fos.write(data.getBytes("UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (fos != null)
                try {
                    fos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
        }
    }
}