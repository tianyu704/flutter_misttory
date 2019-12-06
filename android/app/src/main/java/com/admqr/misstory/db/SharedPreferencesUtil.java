package com.admqr.misstory.db;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * Created by hugo on 18/6/27
 */
public class SharedPreferencesUtil {
    private static final String IS_CAN_START_WORK_SERVICE = "isCanStartWorkService";
    private static final String LOCATION_INTERVAL = "location_interval";

    private SharedPreferences mPref;
    private SharedPreferences.Editor mEditor;
    private static SharedPreferencesUtil mSharedPreferencesUtil;

    public SharedPreferencesUtil(Context context) {
        mPref = context.getSharedPreferences("AKey_Config", 0);
        SharedPreferences.Editor localEditor = mPref.edit();
        mEditor = localEditor;
    }

    public static SharedPreferencesUtil getInstance(Context context) {
        if (mSharedPreferencesUtil == null) {
            mSharedPreferencesUtil = new SharedPreferencesUtil(context);
        }
        return mSharedPreferencesUtil;
    }

    public void setIsCanStartWorkService(boolean isCanStartWorkService) {
        mEditor.putBoolean(IS_CAN_START_WORK_SERVICE, isCanStartWorkService);
        mEditor.commit();
    }

    public boolean isCanStartWorkService() {
        return mPref.getBoolean(IS_CAN_START_WORK_SERVICE, false);
    }

    public void setLocationInterval(int interval) {
        mEditor.putInt(LOCATION_INTERVAL, interval);
        mEditor.commit();
    }

    public int getLocationInterval() {
        return mPref.getInt(LOCATION_INTERVAL, 2 * 60 * 1000);
    }
}
