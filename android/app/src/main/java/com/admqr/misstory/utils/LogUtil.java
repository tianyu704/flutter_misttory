package com.admqr.misstory.utils;

import android.text.TextUtils;
import android.util.Log;

import com.admqr.misstory.BuildConfig;

public class LogUtil {

    private static boolean debug = BuildConfig.DEBUG;

    public static boolean isDebug() {
        return debug;
    }

    public static void setDebug(boolean debug) {
        LogUtil.debug = debug;
    }

    public static String makeLogTag(Class<?> cls) {
        return "Misstory_" + cls.getSimpleName();
    }

    public static void v(String tag, String msg) {
        if (debug && !TextUtils.isEmpty(msg)) {
            Log.v(tag, msg);
        }
    }

    public static void d(String tag, String msg) {
        if (debug && !TextUtils.isEmpty(msg)) {
            Log.d(tag, msg);
        }
    }

    public static void i(String tag, String msg) {
        if (debug && !TextUtils.isEmpty(msg)) {
            int maxLogSize = 1000;
            for (int i = 0; i <= msg.length() / maxLogSize; i++) {
                int start = i * maxLogSize;
                int end = (i + 1) * maxLogSize;
                end = end > msg.length() ? msg.length() : end;
                Log.i(tag, msg.substring(start, end));
            }
        }
    }

    public static void w(String tag, String msg) {
        if (debug && !TextUtils.isEmpty(msg)) {
            int maxLogSize = 1000;
            for (int i = 0; i <= msg.length() / maxLogSize; i++) {
                int start = i * maxLogSize;
                int end = (i + 1) * maxLogSize;
                end = end > msg.length() ? msg.length() : end;
                Log.w(tag, msg.substring(start, end));
            }
        }
    }

    public static void e(String tag, String msg) {
        if (debug && !TextUtils.isEmpty(msg)) {
            Log.e(tag, msg);
        }

    }

    public static void e(String tag, String msg, Throwable tr) {
        if (debug && !TextUtils.isEmpty(msg)) {
            Log.e(tag, msg, tr);
        }
    }

}
