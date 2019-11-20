package com.admqr.misstory.eventbus;

import com.admqr.misstory.model.LocationData;

/**
 * Created by hugo on 2019-11-18
 */
public class LocationEvent {
    public final LocationData locationData;

    public LocationEvent(LocationData locationData) {
        this.locationData = locationData;
    }
}
