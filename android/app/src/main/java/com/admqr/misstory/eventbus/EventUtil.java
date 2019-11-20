package com.admqr.misstory.eventbus;

import com.admqr.misstory.model.LocationData;

import org.greenrobot.eventbus.EventBus;

/**
 * Created by hugoguo on 2017/7/6.
 */

public class EventUtil {

    public static void register(Object subscriber) {
        if (!EventBus.getDefault().isRegistered(subscriber)) {
            EventBus.getDefault().register(subscriber);
        }
    }

    public static void unregister(Object subscriber) {
        EventBus.getDefault().unregister(subscriber);
    }

    public static void post(Object event) {
        EventBus.getDefault().post(event);
    }

    public static void postLocationEvent(LocationData locationData) {
        post(new LocationEvent(locationData));
    }

}
