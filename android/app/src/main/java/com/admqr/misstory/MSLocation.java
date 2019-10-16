package com.admqr.misstory;

import java.io.Serializable;

import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;

/**
 * Created by hugo on 2019-10-10
 */
public class MSLocation extends RealmObject implements Serializable {

    private static final long serialVersionUID = -1188208422160795548L;
    /**
     * id : 1
     * altitude : 0
     * speed : 0
     * bearing : 0
     * citycode : 010
     * adcode : 110105
     * country : 中国
     * province : 北京市
     * city : 北京市
     * district : 朝阳区
     * road : 百子湾路
     * street : 百子湾路
     * number : 76 号楼
     * poiname : 中国建设银行(北京百子湾路支行)
     * errorCode : 0
     * errorInfo : success
     * locationType : 5
     * locationDetail : #csid: 6 daae0af9bdb4201992732471233daf0
     * aoiname : 金隅· 大成国际中心
     * address : 北京市朝阳区百子湾路76号楼靠近中国建设银行(北京百子湾路支行)
     * poiid : B000AA4IXH
     * floor :
     * description : 在中国建设银行(北京百子湾路支行) 附近
     * time : 1569397020585
     * updatetime : 1569397020585
     * provider : lbs
     * lon : 116.492711
     * lat : 39.900209
     * accuracy : 29
     * isOffset : true
     * isFixLastLocation : false
     * coordType : GCJ02
     * is_delete : true
     */
    @PrimaryKey
    private long id;
    private double altitude;
    private float speed;
    private float bearing;
    private String citycode;
    private String adcode;
    private String country;
    private String province;
    private String city;
    private String district;
    private String road;
    private String street;
    private String number;
    private String poiname;
    private int errorCode;
    private String errorInfo;
    private int locationType;
    private String locationDetail;
    private String aoiname;
    private String address;
    private String poiid;
    private String floor;
    private String description;
    private long time;
    private long updatetime;
    private String provider;
    private double lon;
    private double lat;
    private float accuracy;
    private boolean isOffset;
    private boolean isFixLastLocation;
    private String coordType;
    private boolean is_delete;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public double getAltitude() {
        return altitude;
    }

    public void setAltitude(double altitude) {
        this.altitude = altitude;
    }

    public float getSpeed() {
        return speed;
    }

    public void setSpeed(float speed) {
        this.speed = speed;
    }

    public float getBearing() {
        return bearing;
    }

    public void setBearing(float bearing) {
        this.bearing = bearing;
    }

    public String getCitycode() {
        return citycode;
    }

    public void setCitycode(String citycode) {
        this.citycode = citycode;
    }

    public String getAdcode() {
        return adcode;
    }

    public void setAdcode(String adcode) {
        this.adcode = adcode;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getRoad() {
        return road;
    }

    public void setRoad(String road) {
        this.road = road;
    }

    public String getStreet() {
        return street;
    }

    public void setStreet(String street) {
        this.street = street;
    }

    public String getNumber() {
        return number;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    public String getPoiname() {
        return poiname;
    }

    public void setPoiname(String poiname) {
        this.poiname = poiname;
    }

    public int getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(int errorCode) {
        this.errorCode = errorCode;
    }

    public String getErrorInfo() {
        return errorInfo;
    }

    public void setErrorInfo(String errorInfo) {
        this.errorInfo = errorInfo;
    }

    public int getLocationType() {
        return locationType;
    }

    public void setLocationType(int locationType) {
        this.locationType = locationType;
    }

    public String getLocationDetail() {
        return locationDetail;
    }

    public void setLocationDetail(String locationDetail) {
        this.locationDetail = locationDetail;
    }

    public String getAoiname() {
        return aoiname;
    }

    public void setAoiname(String aoiname) {
        this.aoiname = aoiname;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getPoiid() {
        return poiid;
    }

    public void setPoiid(String poiid) {
        this.poiid = poiid;
    }

    public String getFloor() {
        return floor;
    }

    public void setFloor(String floor) {
        this.floor = floor;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }

    public long getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(long updatetime) {
        this.updatetime = updatetime;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public double getLon() {
        return lon;
    }

    public void setLon(double lon) {
        this.lon = lon;
    }

    public double getLat() {
        return lat;
    }

    public void setLat(double lat) {
        this.lat = lat;
    }

    public float getAccuracy() {
        return accuracy;
    }

    public void setAccuracy(float accuracy) {
        this.accuracy = accuracy;
    }

    public boolean isOffset() {
        return isOffset;
    }

    public void setOffset(boolean offset) {
        isOffset = offset;
    }

    public boolean isFixLastLocation() {
        return isFixLastLocation;
    }

    public void setFixLastLocation(boolean fixLastLocation) {
        isFixLastLocation = fixLastLocation;
    }

    public String getCoordType() {
        return coordType;
    }

    public void setCoordType(String coordType) {
        this.coordType = coordType;
    }

    public boolean isIs_delete() {
        return is_delete;
    }

    public void setIs_delete(boolean is_delete) {
        this.is_delete = is_delete;
    }
}
