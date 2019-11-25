GEO="39.898907,116.486516"
GEO_US="40.815361,-73.918555"

echo '\n\n> 腾讯接口' #需要坐标偏移
QQ_MAP_KEY="24DBZ-IJFC4-YSYUQ-D2NAI-LYXDO-4HFUV"
URL3="https://apis.map.qq.com/ws/geocoder/v1/?location=${GEO}&key=${QQ_MAP_KEY}&get_poi=1"
curl "$URL3"

echo '\n\n> HERE接口'
URL4="https://reverse.geocoder.api.here.com/6.2/reversegeocode.json?language=zh-Hant&mode=retrieveAll&locationattributes=mapView&prox=${GEO_US},100&app_id=mliiuE1IEOvUEzCyxSRV&app_code=8yiJaBQVH2pe7El2kwQUFA"
curl "$URL4"