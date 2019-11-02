package com.admqr.misstory.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.List;

/**
 * Created by hugo on 2019-10-31
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public class LocationResult {

    /**
     * meta : {"code":200,"requestId":"5dba5b51598e64002cd86c96"}
     * response : {"venues":[{"id":"4ba85b99f964a520ebd739e3","name":"大成国际中心","location":{"address":"北京","crossStreet":"testing","lat":39.89933004890814,"lng":116.48662522626427,"labeledLatLngs":[{"label":"display","lat":39.89933004890814,"lng":116.48662522626427}],"distance":55,"postalCode":"中国","cc":"CN","city":"朝外","state":"北京市","country":"中国","formattedAddress":["北京 (testing)","朝外","北京市, 中国","中国"]},"categories":[{"id":"4bf58dd8d48988d1e1931735","name":"Arcade","pluralName":"Arcades","shortName":"Arcade","icon":{"prefix":"https://ss3.4sqi.net/img/categories_v2/arts_entertainment/arcade_","suffix":".png"},"primary":true}],"referralId":"v-1572494161","hasPerk":false}],"confident":false}
     */

    private MetaBean meta;
    private ResponseBean response;

    public MetaBean getMeta() {
        return meta;
    }

    public void setMeta(MetaBean meta) {
        this.meta = meta;
    }

    public ResponseBean getResponse() {
        return response;
    }

    public void setResponse(ResponseBean response) {
        this.response = response;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class MetaBean {
        /**
         * code : 200
         * requestId : 5dba5b51598e64002cd86c96
         */

        private int code;
        private String requestId;

        public int getCode() {
            return code;
        }

        public void setCode(int code) {
            this.code = code;
        }

        public String getRequestId() {
            return requestId;
        }

        public void setRequestId(String requestId) {
            this.requestId = requestId;
        }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class ResponseBean {
        /**
         * venues : [{"id":"4ba85b99f964a520ebd739e3","name":"大成国际中心","location":{"address":"北京","crossStreet":"testing","lat":39.89933004890814,"lng":116.48662522626427,"labeledLatLngs":[{"label":"display","lat":39.89933004890814,"lng":116.48662522626427}],"distance":55,"postalCode":"中国","cc":"CN","city":"朝外","state":"北京市","country":"中国","formattedAddress":["北京 (testing)","朝外","北京市, 中国","中国"]},"categories":[{"id":"4bf58dd8d48988d1e1931735","name":"Arcade","pluralName":"Arcades","shortName":"Arcade","icon":{"prefix":"https://ss3.4sqi.net/img/categories_v2/arts_entertainment/arcade_","suffix":".png"},"primary":true}],"referralId":"v-1572494161","hasPerk":false}]
         * confident : false
         */

        private boolean confident;
        private List<VenuesBean> venues;

        public boolean isConfident() {
            return confident;
        }

        public void setConfident(boolean confident) {
            this.confident = confident;
        }

        public List<VenuesBean> getVenues() {
            return venues;
        }

        public void setVenues(List<VenuesBean> venues) {
            this.venues = venues;
        }

        @JsonIgnoreProperties(ignoreUnknown = true)
        public static class VenuesBean {
            /**
             * id : 4ba85b99f964a520ebd739e3
             * name : 大成国际中心
             * location : {"address":"北京","crossStreet":"testing","lat":39.89933004890814,"lng":116.48662522626427,"labeledLatLngs":[{"label":"display","lat":39.89933004890814,"lng":116.48662522626427}],"distance":55,"postalCode":"中国","cc":"CN","city":"朝外","state":"北京市","country":"中国","formattedAddress":["北京 (testing)","朝外","北京市, 中国","中国"]}
             * categories : [{"id":"4bf58dd8d48988d1e1931735","name":"Arcade","pluralName":"Arcades","shortName":"Arcade","icon":{"prefix":"https://ss3.4sqi.net/img/categories_v2/arts_entertainment/arcade_","suffix":".png"},"primary":true}]
             * referralId : v-1572494161
             * hasPerk : false
             */

            private String id;
            private String name;
            private LocationBean location;
            private String referralId;
            private boolean hasPerk;
            private List<CategoriesBean> categories;

            public String getId() {
                return id;
            }

            public void setId(String id) {
                this.id = id;
            }

            public String getName() {
                return name;
            }

            public void setName(String name) {
                this.name = name;
            }

            public LocationBean getLocation() {
                return location;
            }

            public void setLocation(LocationBean location) {
                this.location = location;
            }

            public String getReferralId() {
                return referralId;
            }

            public void setReferralId(String referralId) {
                this.referralId = referralId;
            }

            public boolean isHasPerk() {
                return hasPerk;
            }

            public void setHasPerk(boolean hasPerk) {
                this.hasPerk = hasPerk;
            }

            public List<CategoriesBean> getCategories() {
                return categories;
            }

            public void setCategories(List<CategoriesBean> categories) {
                this.categories = categories;
            }

            @JsonIgnoreProperties(ignoreUnknown = true)
            public static class LocationBean {
                /**
                 * address : 北京
                 * crossStreet : testing
                 * lat : 39.89933004890814
                 * lng : 116.48662522626427
                 * labeledLatLngs : [{"label":"display","lat":39.89933004890814,"lng":116.48662522626427}]
                 * distance : 55
                 * postalCode : 中国
                 * cc : CN
                 * city : 朝外
                 * state : 北京市
                 * country : 中国
                 * formattedAddress : ["北京 (testing)","朝外","北京市, 中国","中国"]
                 */

                private String address;
                private String crossStreet;
                private double lat;
                private double lng;
                private int distance;
                private String postalCode;
                private String cc;
                private String city;
                private String state;
                private String country;
                private List<LabeledLatLngsBean> labeledLatLngs;
                private List<String> formattedAddress;

                public String getAddress() {
                    return address;
                }

                public void setAddress(String address) {
                    this.address = address;
                }

                public String getCrossStreet() {
                    return crossStreet;
                }

                public void setCrossStreet(String crossStreet) {
                    this.crossStreet = crossStreet;
                }

                public double getLat() {
                    return lat;
                }

                public void setLat(double lat) {
                    this.lat = lat;
                }

                public double getLng() {
                    return lng;
                }

                public void setLng(double lng) {
                    this.lng = lng;
                }

                public int getDistance() {
                    return distance;
                }

                public void setDistance(int distance) {
                    this.distance = distance;
                }

                public String getPostalCode() {
                    return postalCode;
                }

                public void setPostalCode(String postalCode) {
                    this.postalCode = postalCode;
                }

                public String getCc() {
                    return cc;
                }

                public void setCc(String cc) {
                    this.cc = cc;
                }

                public String getCity() {
                    return city;
                }

                public void setCity(String city) {
                    this.city = city;
                }

                public String getState() {
                    return state;
                }

                public void setState(String state) {
                    this.state = state;
                }

                public String getCountry() {
                    return country;
                }

                public void setCountry(String country) {
                    this.country = country;
                }

                public List<LabeledLatLngsBean> getLabeledLatLngs() {
                    return labeledLatLngs;
                }

                public void setLabeledLatLngs(List<LabeledLatLngsBean> labeledLatLngs) {
                    this.labeledLatLngs = labeledLatLngs;
                }

                public List<String> getFormattedAddress() {
                    return formattedAddress;
                }

                public void setFormattedAddress(List<String> formattedAddress) {
                    this.formattedAddress = formattedAddress;
                }

                @JsonIgnoreProperties(ignoreUnknown = true)
                public static class LabeledLatLngsBean {
                    /**
                     * label : display
                     * lat : 39.89933004890814
                     * lng : 116.48662522626427
                     */

                    private String label;
                    private double lat;
                    private double lng;

                    public String getLabel() {
                        return label;
                    }

                    public void setLabel(String label) {
                        this.label = label;
                    }

                    public double getLat() {
                        return lat;
                    }

                    public void setLat(double lat) {
                        this.lat = lat;
                    }

                    public double getLng() {
                        return lng;
                    }

                    public void setLng(double lng) {
                        this.lng = lng;
                    }
                }
            }

            @JsonIgnoreProperties(ignoreUnknown = true)
            public static class CategoriesBean {
                /**
                 * id : 4bf58dd8d48988d1e1931735
                 * name : Arcade
                 * pluralName : Arcades
                 * shortName : Arcade
                 * icon : {"prefix":"https://ss3.4sqi.net/img/categories_v2/arts_entertainment/arcade_","suffix":".png"}
                 * primary : true
                 */

                private String id;
                private String name;
                private String pluralName;
                private String shortName;
                private IconBean icon;
                private boolean primary;

                public String getId() {
                    return id;
                }

                public void setId(String id) {
                    this.id = id;
                }

                public String getName() {
                    return name;
                }

                public void setName(String name) {
                    this.name = name;
                }

                public String getPluralName() {
                    return pluralName;
                }

                public void setPluralName(String pluralName) {
                    this.pluralName = pluralName;
                }

                public String getShortName() {
                    return shortName;
                }

                public void setShortName(String shortName) {
                    this.shortName = shortName;
                }

                public IconBean getIcon() {
                    return icon;
                }

                public void setIcon(IconBean icon) {
                    this.icon = icon;
                }

                public boolean isPrimary() {
                    return primary;
                }

                public void setPrimary(boolean primary) {
                    this.primary = primary;
                }

                @JsonIgnoreProperties(ignoreUnknown = true)
                public static class IconBean {
                    /**
                     * prefix : https://ss3.4sqi.net/img/categories_v2/arts_entertainment/arcade_
                     * suffix : .png
                     */

                    private String prefix;
                    private String suffix;

                    public String getPrefix() {
                        return prefix;
                    }

                    public void setPrefix(String prefix) {
                        this.prefix = prefix;
                    }

                    public String getSuffix() {
                        return suffix;
                    }

                    public void setSuffix(String suffix) {
                        this.suffix = suffix;
                    }
                }
            }
        }
    }
}
