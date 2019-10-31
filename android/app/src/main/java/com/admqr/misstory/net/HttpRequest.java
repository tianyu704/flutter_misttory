package com.admqr.misstory.net;

import android.util.Log;

import com.admqr.misstory.model.MSLocation;
import com.admqr.misstory.utils.LogUtil;
import com.lzy.okgo.OkGo;
import com.lzy.okgo.callback.StringCallback;
import com.lzy.okgo.model.Response;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by hugo on 2019-10-30
 */
public class HttpRequest {
    static final String TAG = LogUtil.makeLogTag(HttpRequest.class);
    public static final String locationTag = "locationTag";
    static final String CLIENT_ID = "PVMPPN4X34GCG44Z1SMNPD5YAHFORLSEUSNJSNUN0VNM5DXS";
    static final String CLIENT_SECRET = "N0IHDULNBN0ZFZKUSX1N2YKRSZBZK11UQ2KW4LFJ2S1KBURD";

    //在访问HttpRequest时创建单例
    private static class SingletonHolder {
        private static final HttpRequest INSTANCE = new HttpRequest();
    }

    //获取单例
    public static HttpRequest getInstance() {
        return SingletonHolder.INSTANCE;
    }

    public void cancel(String tag){
        OkGo.getInstance().cancelTag(tag);
    }

    public void requestLocation(String latLon,StringCallback callBack) {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
        String v = dateFormat.format(new Date());
        OkGo.<String>get("https://api.foursquare.com/v2/venues/search?")
                .tag(locationTag)
                .params("client_id", CLIENT_ID)
                .params("client_secret", CLIENT_SECRET)
                .params("limit", 1)
                .params("v", v)
                .params("ll", latLon)
                .execute(callBack);
    }
}
