package com.admqr.misstory.utils;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.admqr.misstory.model.LocationData;
import com.admqr.misstory.net.HttpRequest;
import com.lzy.okgo.callback.StringCallback;
import com.lzy.okgo.model.Response;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

/**
 * Created by hugo on 2019-10-30
 */
public class LocationUtil {
    static final String TAG = "LocationUtil";
    static final int REQUEST_PERMISSION = 1000;
    private Context context;
    private LocationManager locationManager;
    private MSLocationListener msLocationListener;
    private boolean isStarted = false;
    public static int interval = 3 * 60 * 1000;
    public static int distance = 10;
    GeocodeAddress geocodeAddress;

    public LocationUtil(Context context) {
        this.context = context;
        locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
    }

    public void setMsLocationListener(MSLocationListener msLocationListener) {
        this.msLocationListener = msLocationListener;
    }

    public boolean isStarted() {
        return isStarted;
    }

    public void start() {
        if (locationManager == null) {
            return;
        }
        Log.d(TAG, "start");
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                && ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            String provider = getProvider();
            if (!TextUtils.isEmpty(provider)) {
                isStarted = true;
                locationManager.requestLocationUpdates(getProvider(), 0, distance, locationListener);
            }
        }
    }

    public void startOnce(MSLocationListener msLocationListener) {
        if (locationManager == null) {
            return;
        }
        this.msLocationListener = msLocationListener;
        Log.d(TAG, "startOnce");
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                && ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            String provider = getProvider();
            if (!TextUtils.isEmpty(provider)) {
                isStarted = true;
                locationManager.requestLocationUpdates(getProvider(), 10 * 1000, 10, locationListener);
            }
        }
    }

    public void stop() {
        if (locationManager == null) {
            return;
        }
        Log.d(TAG, "stop");
        locationManager.removeUpdates(locationListener);
        isStarted = false;
    }

    public String getProvider() {
//        // Criteria是一组筛选条件
//        Criteria criteria = new Criteria();
//        //设置定位精准度
//        criteria.setAccuracy(Criteria.ACCURACY_FINE);
//        //是否要求海拔
//        criteria.setAltitudeRequired(true);
//        //是否要求方向
//        criteria.setBearingRequired(true);
//        //是否要求收费
//        criteria.setCostAllowed(true);
//        //是否要求速度
//        criteria.setSpeedRequired(true);
//        //设置电池耗电要求
//        criteria.setPowerRequirement(Criteria.NO_REQUIREMENT);
//        //设置方向精确度
//        criteria.setBearingAccuracy(Criteria.ACCURACY_LOW);
//        //设置速度精确度
//        criteria.setSpeedAccuracy(Criteria.ACCURACY_LOW);
//        //设置水平方向精确度
//        criteria.setHorizontalAccuracy(Criteria.ACCURACY_HIGH);
//        //设置垂直方向精确度
//        criteria.setVerticalAccuracy(Criteria.ACCURACY_HIGH);
//        //返回满足条件的当前设备可用的provider，第二个参数为false时返回当前设备所有provider中最符合条件的那个provider，但是不一定可用
//        String mProvider = locationManager.getBestProvider(criteria, true);
//        Log.d(TAG, "bestProvider:" + mProvider);

        if (locationManager == null) {
            return "";
        }
        String locationProvider = "";
        List<String> providers = locationManager.getProviders(true);
        if (providers.contains(LocationManager.GPS_PROVIDER)) {
            //如果是GPS定位
            locationProvider = LocationManager.GPS_PROVIDER;
        } else if (providers.contains(LocationManager.NETWORK_PROVIDER)) {
            //如果是网络定位
            locationProvider = LocationManager.NETWORK_PROVIDER;
        } else {
            Toast.makeText(context, "Please Open Your GPS or Location Service", Toast.LENGTH_SHORT).show();
        }
        return locationProvider;
    }

    private LocationListener locationListener = new LocationListener() {
        @Override
        public void onLocationChanged(Location location) {
//            LogUtil.d(TAG, JacksonUtil.getInstance().writeValueAsString(location));
            Log.d(TAG, "onLocationChanged:" + location.getLatitude() + "," + location.getLongitude());
            if (msLocationListener != null && location != null) {
                LocationData locationData = new LocationData();
                locationData.setAccuracy(location.getAccuracy());
                locationData.setAltitude(location.getAltitude());
                locationData.setLat(location.getLatitude());
                locationData.setLon(location.getLongitude());
                locationData.setBearing(location.getBearing());
                locationData.setId(UUID.randomUUID().toString());
                locationData.setSpeed(location.getSpeed());
                locationData.setTime(location.getTime());
                locationData.setCoordType("WGS84");
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    locationData.setVerticalAccuracy(location.getVerticalAccuracyMeters());
                }
                msLocationListener.onLocationChanged(locationData);
//                geocodeAddress = new GeocodeAddress();
//                geocodeAddress.execute(location);
//                HttpRequest.getInstance().requestLocation(location.getLatitude() + "," + location.getLongitude(), new StringCallback() {
//                    @Override
//                    public void onSuccess(Response<String> response) {
//
//                    }
//                });
            }
            if (location != null) {
                stop();
            }
        }

        @Override
        public void onStatusChanged(String s, int i, Bundle bundle) {
            Log.d(TAG, "onStatusChanged-->provider:" + s + ",status:" + i + ",extras:" + bundle.toString());
        }

        @Override
        public void onProviderEnabled(String s) {
            Log.d(TAG, "onProviderEnabled:" + s);
            start();
        }

        @Override
        public void onProviderDisabled(String s) {
            Log.d(TAG, "onProviderDisabled:" + s);
            start();
        }
    };

    public class GeocodeAddress extends AsyncTask<Location, Void, String> {

        @Override
        protected void onPreExecute() {
            // TODO Auto-generated method stub
            super.onPreExecute();
        }

        @Override
        protected String doInBackground(Location... params) {
            // TODO Auto-generated method stub
            if (params[0] != null) {

//                Geocoder geocoder = new Geocoder(context);
//                try {
//                    List<Address> address = geocoder.getFromLocation(38.4307949819,115.9315904557, 1);
//                    if (address != null && address.size() > 0) {
//                        Log.d(TAG, JacksonUtil.getInstance().writeValueAsString(address.get(0)));
//                    }
//                } catch (IOException e) {
//                    // TODO Auto-generated catch block
//                    e.printStackTrace();
//                }
            }
            return null;
        }

        @Override
        protected void onPostExecute(String result) {
            // TODO Auto-generated method stub

        }

    }

    public static boolean hasPermission(Context context) {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                && ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            return true;
        }
        return false;
    }

    public static void requestPermission(Activity activity) {
        ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        Manifest.permission.READ_PHONE_STATE, Manifest.permission.ACCESS_FINE_LOCATION},
                REQUEST_PERMISSION);

    }

    private static final int TWO_MINUTES = 1000 * 60 * 2;

    /**
     * Determines whether one Location reading is better than the current Location fix
     *
     * @param location            The new Location that you want to evaluate
     * @param currentBestLocation The current Location fix, to which you want to compare the new one
     */
    protected boolean isBetterLocation(Location location, Location currentBestLocation) {
        if (currentBestLocation == null) {
            // A new location is always better than no location
            return true;
        }
        // Check whether the new location fix is newer or older
        long timeDelta = location.getTime() - currentBestLocation.getTime();
        boolean isSignificantlyNewer = timeDelta > TWO_MINUTES;
        boolean isSignificantlyOlder = timeDelta < -TWO_MINUTES;
        boolean isNewer = timeDelta > 0;
        // If it's been more than two minutes since the current location, use the new location
        // because the user has likely moved
        if (isSignificantlyNewer) {
            return true;
            // If the new location is more than two minutes older, it must be worse
        } else if (isSignificantlyOlder) {
            return false;
        }
        // Check whether the new location fix is more or less accurate
        int accuracyDelta = (int) (location.getAccuracy() - currentBestLocation.getAccuracy());
        boolean isLessAccurate = accuracyDelta > 0;
        boolean isMoreAccurate = accuracyDelta < 0;
        boolean isSignificantlyLessAccurate = accuracyDelta > 200;
        // Check if the old and new location are from the same provider
        boolean isFromSameProvider = isSameProvider(location.getProvider(),
                currentBestLocation.getProvider());
        // Determine location quality using a combination of timeliness and accuracy
        if (isMoreAccurate) {
            return true;
        } else if (isNewer && !isLessAccurate) {
            return true;
        } else if (isNewer && !isSignificantlyLessAccurate && isFromSameProvider) {
            return true;
        }
        return false;
    }

    /**
     * Checks whether two providers are the same
     */
    private boolean isSameProvider(String provider1, String provider2) {
        if (provider1 == null) {
            return provider2 == null;
        }
        return provider1.equals(provider2);
    }

    public interface MSLocationListener {
        void onLocationChanged(LocationData location);
    }
}
