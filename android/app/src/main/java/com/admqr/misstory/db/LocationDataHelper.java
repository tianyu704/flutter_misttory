package com.admqr.misstory.db;

import com.admqr.misstory.model.LocationData;
import com.admqr.misstory.utils.LogUtil;

import java.util.List;

import io.realm.Realm;
import io.realm.RealmResults;

/**
 * Created by hugo on 2019-11-19
 */
public class LocationDataHelper {
    private static final String TAG = LogUtil.makeLogTag(LocationDataHelper.class);

    private static class Holder {
        private final static LocationDataHelper instance = new LocationDataHelper();
    }

    public static LocationDataHelper getInstance() {
        return LocationDataHelper.Holder.instance;
    }

    //创建location
    public void createLocation(LocationData locationData) {
        if (locationData != null) {
            Realm realm = Realm.getDefaultInstance();
            try {
                realm.beginTransaction();
                realm.copyToRealmOrUpdate(locationData);
                realm.commitTransaction();
            } finally {
                realm.close();
            }
        }
    }

    //查询所有Location
    public List<LocationData> getAllLocation() {
        Realm realm = Realm.getDefaultInstance();//获取Realm实例
        try {
            RealmResults<LocationData> results = realm.where(LocationData.class).findAll();
            List<LocationData> locations = realm.copyFromRealm(results);
            return locations;
        } finally {
            realm.close();
        }
    }

    //清除所有Location
    public void clearLocation() {
        Realm mRealm = Realm.getDefaultInstance();//获取Realm实例
        try {
            mRealm.executeTransaction(realm -> {
                realm.delete(LocationData.class);
            });
        } finally {
            mRealm.close();
        }


    }
}
