package com.admqr.misstory.utils;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.GnssStatus;
import android.location.GpsSatellite;
import android.location.GpsStatus;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.admqr.misstory.model.LocationData;
import com.admqr.misstory.net.HttpRequest;
import com.lzy.okgo.callback.StringCallback;
import com.lzy.okgo.model.Response;

import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

import static android.os.Build.VERSION_CODES.N;

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
    public static int timeout = 5 * 1000;
    private String provider = LocationManager.NETWORK_PROVIDER;
    private boolean isSearching = false;

    private static class Holder {
        private final static LocationUtil instance = new LocationUtil();
    }

    public static LocationUtil getInstance() {
        return Holder.instance;
    }

    public void init(Context context) {
        this.context = context;
        locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
    }

    public boolean isStarted() {
        return isStarted;
    }

    private Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            if (isSearching) {
                if (Build.VERSION.SDK_INT >= N) {
                    locationManager.unregisterGnssStatusCallback(gnssStatusCallback);
                    startLocation();
                } else {
                    locationManager.removeGpsStatusListener(gpsStatusListener);
                    startLocation();
                }
            }
        }
    };
//    public void start() {
//        if (locationManager == null) {
//            return;
//        }
//        Log.d(TAG, "start");
//        if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
//                && ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
//            if (!TextUtils.isEmpty(provider)) {
//                LogUtil.d(TAG, "provider:" + provider);
//                isStarted = true;
//                locationManager.requestLocationUpdates(provider, 0, distance, locationListener);
//            }
//        }
//    }

    public void startOnce(MSLocationListener msLocationListener) {
        Log.d(TAG, "startOnce");
        if (locationManager == null) {
            return;
        }
        stop();
        this.msLocationListener = msLocationListener;
        startGnssStatusListener();
        handler.sendEmptyMessageDelayed(0, timeout);
    }

    public void startLocation() {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                && ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            if (!TextUtils.isEmpty(provider)) {
                LogUtil.d(TAG, "provider:" + provider);
                isStarted = true;
                locationManager.requestSingleUpdate(provider, new LocationListener() {
                    @Override
                    public void onLocationChanged(Location location) {
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
                            locationData.setProvider(location.getProvider());
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                locationData.setVerticalAccuracy(location.getVerticalAccuracyMeters());
                            }
                            msLocationListener.onLocationChanged(locationData);
                            stop();
                        }
                    }

                    @Override
                    public void onStatusChanged(String provider, int status, Bundle extras) {

                    }

                    @Override
                    public void onProviderEnabled(String provider) {

                    }

                    @Override
                    public void onProviderDisabled(String provider) {

                    }
                }, null);
            }
        }
    }

    public void stop() {
        if (locationManager == null) {
            return;
        }
        if (locationListener != null) {
            Log.d(TAG, "stop");
            locationManager.removeUpdates(locationListener);
            isStarted = false;
        }
    }


    public void startGnssStatusListener() {
        if (locationManager == null) {
            return;
        }
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                && ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            isSearching = true;
            if (Build.VERSION.SDK_INT >= N) {
                locationManager.registerGnssStatusCallback(gnssStatusCallback);
            } else {
                locationManager.addGpsStatusListener(gpsStatusListener);
            }
        }
    }

    @RequiresApi(N)
    private GnssStatus.Callback gnssStatusCallback = new GnssStatus.Callback() {
        @Override
        public void onSatelliteStatusChanged(GnssStatus status) {
            super.onSatelliteStatusChanged(status);
            LogUtil.d(TAG, "gnss status changed");
            int count = 0;
            if (status != null && status.getSatelliteCount() > 0) {
                for (int i = 0; i < status.getSatelliteCount(); i++) {
                    if (status.getCn0DbHz(i) > 0) {
                        count++;
                    }
                }
                if (count >= 4) {
                    provider = LocationManager.GPS_PROVIDER;
                } else {
                    provider = LocationManager.NETWORK_PROVIDER;
                }
            } else {
                provider = LocationManager.NETWORK_PROVIDER;
            }
            LogUtil.d(TAG, "可用卫星数量：" + count + "个，定位类型为:" + provider);
            locationManager.unregisterGnssStatusCallback(this);
            isSearching = false;
            startLocation();
        }
    };

    @SuppressLint("MissingPermission")
    private GpsStatus.Listener gpsStatusListener = new GpsStatus.Listener() {
        @Override
        public void onGpsStatusChanged(int event) {
            if (event == GpsStatus.GPS_EVENT_SATELLITE_STATUS) {
                LogUtil.d(TAG, "gnss status changed");
                GpsStatus status = locationManager.getGpsStatus(null);
                int count = 0;
                if (status != null && status.getMaxSatellites() > 0) {
                    Iterator<GpsSatellite> iters = status.getSatellites().iterator();
                    while (iters.hasNext()) {
                        if (iters.next().getSnr() > 0) {
                            count++;
                        }
                    }
                    if (count >= 4) {
                        provider = LocationManager.GPS_PROVIDER;
                    } else {
                        provider = LocationManager.NETWORK_PROVIDER;
                    }
                } else {
                    provider = LocationManager.NETWORK_PROVIDER;
                }
                LogUtil.d(TAG, "可用卫星数量：" + count + "个，定位类型为:" + provider);
                locationManager.removeGpsStatusListener(this);
                isSearching = false;
                startLocation();
            }
        }
    };


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
//            start();
        }

        @Override
        public void onProviderDisabled(String s) {
            Log.d(TAG, "onProviderDisabled:" + s);
//            start();
        }
    };


//    public String getProvider() {
////        // Criteria是一组筛选条件
////        Criteria criteria = new Criteria();
////        //设置定位精准度
////        criteria.setAccuracy(Criteria.ACCURACY_FINE);
////        //是否要求海拔
////        criteria.setAltitudeRequired(true);
////        //是否要求方向
////        criteria.setBearingRequired(true);
////        //是否要求收费
////        criteria.setCostAllowed(true);
////        //是否要求速度
////        criteria.setSpeedRequired(true);
////        //设置电池耗电要求
////        criteria.setPowerRequirement(Criteria.NO_REQUIREMENT);
////        //设置方向精确度
////        criteria.setBearingAccuracy(Criteria.ACCURACY_LOW);
////        //设置速度精确度
////        criteria.setSpeedAccuracy(Criteria.ACCURACY_LOW);
////        //设置水平方向精确度
////        criteria.setHorizontalAccuracy(Criteria.ACCURACY_HIGH);
////        //设置垂直方向精确度
////        criteria.setVerticalAccuracy(Criteria.ACCURACY_HIGH);
////        //返回满足条件的当前设备可用的provider，第二个参数为false时返回当前设备所有provider中最符合条件的那个provider，但是不一定可用
////        String mProvider = locationManager.getBestProvider(criteria, true);
////        Log.d(TAG, "bestProvider:" + mProvider);
//
//        if (locationManager == null) {
//            return "";
//        }
//        String locationProvider = "";
//        List<String> providers = locationManager.getProviders(true);
//        if (providers.contains(LocationManager.GPS_PROVIDER)) {
//            //如果是GPS定位
//            locationProvider = LocationManager.GPS_PROVIDER;
//        } else if (providers.contains(LocationManager.NETWORK_PROVIDER)) {
//            //如果是网络定位
//            locationProvider = LocationManager.NETWORK_PROVIDER;
//        } else {
//            Toast.makeText(context, "Please Open Your GPS or Location Service", Toast.LENGTH_SHORT).show();
//        }
//        return LocationManager.NETWORK_PROVIDER;
//    }


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
