package com.admqr.misstory.utils;

import android.os.Environment;

import java.text.SimpleDateFormat;

/**
 * Created by hugo on 2019-11-26
 */
public class OutputUtil {
    private static final String PATH = Environment.getExternalStorageDirectory().getPath() + "/MisstoryCrash/";

    private static final String FILE_SUFFIX = ".log";

    private static final String TAG = "OutputUtil";

    private SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");


}
