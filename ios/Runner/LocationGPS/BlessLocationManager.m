//
//  BlessLocationManager.m
//  flutter_amap_location_plugin
//
//  Created by HF on 2019/9/28.
//

#import "BlessLocationManager.h"
//#import <CoreLocation/CoreLocation.h>

@interface BlessLocationManager  () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void(^success )(NSString *locationJsonString);
@property (nonatomic, copy) void(^onceSuccess )(NSString *locationJsonString);
@property (nonatomic, assign) CLLocationDistance distanceFilter;
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy;
//
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, assign) BOOL isFirstComein;

@end

@implementation BlessLocationManager

- (instancetype)initWithFilter:(CLLocationDistance)filter accuracy:(CLLocationAccuracy)accuracy
{
    self = [super init];
    if (!self)  return nil;
    self.distanceFilter = filter;
    self.desiredAccuracy = accuracy;
    [self commonInit];
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (!self)  return nil;
    self.distanceFilter = kCLDistanceFilterNone;
    self.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self commonInit];
    return self;
}

- (void)auth
{
    [self.locationManager requestAlwaysAuthorization];// 永久授权
    [self.locationManager requestWhenInUseAuthorization];//使用中授权
}

- (BOOL)locationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

- (void)commonInit
{
    self.locationManager=[[CLLocationManager alloc] init];
    [self auth];
    if ([self locationServicesEnabled]) {
        self.locationManager.delegate = self;
        //默认开启了授权
        //NSLog(@"请开启定位:设置 > 隐私 > 位置 > 定位服务");
        if (@available(iOS 9.0, *)) {
            [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        } else {
                // Fallback on earlier versions
        }
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        self.locationManager.desiredAccuracy =  self.desiredAccuracy;
        self.locationManager.distanceFilter = self.distanceFilter;
        [self.locationManager startUpdatingLocation];
        //支持被kill掉以后能够后台自动重启
        //后台自动唤醒
        [self.locationManager startMonitoringSignificantLocationChanges];
        self.isFirstComein = true;
    }
}


- (NSString *)getCurrentLocationString
{
    if (!self.lastLocation) return @"";
    return [self getJsonStringWithLocation:self.lastLocation];
}

- (void)onceLocationWithSuccess:(void(^)(NSString *locationJsonString))onceSuccess
{
    self.onceSuccess = onceSuccess;
}

- (void)startLocationWithSuccess:(void(^)(NSString *locationJsonString))success
{
    self.success = success;
}

- (void)stop
{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (self.lastDate) {
           long t = [self getSecondsFromStarTime:self.lastDate andInsertEndTime:[NSDate date]];
           if (t < 5) {
               NSLog(@"时间太短了 不记录");
               return;
           }
       }
       self.lastDate = [NSDate date];
       //
       CLLocation *myLocation = locations.firstObject;
       for (CLLocation *l in locations) {
           if (myLocation.horizontalAccuracy < l.horizontalAccuracy) {
               myLocation = l;
           }
       }
       if (self.lastLocation) {
           double distance = [myLocation distanceFromLocation:self.lastLocation];
           if (distance < 2) {
               NSLog(@"太近了 不记录");
              // return;
           }
          // NSLog(@"%@======",@(distance));
       }
    self.lastLocation  = myLocation;
    if (self.isFirstComein) {
        self.isFirstComein = false;
        if (self.onceSuccess) {
            self.onceSuccess([self getJsonStringWithLocation:myLocation]);
        }
        return;
    }
    if (self.success) {
        self.success([self getJsonStringWithLocation:myLocation]);
    }
}

- (NSString *)getJsonStringWithLocation:(CLLocation *)location
{
/**
 
 String id;

 num time;

 num lat;

 num lon;

 num altitude;

 num accuracy;

 @JsonKey(name: "vertical_accuracy")
 num verticalAccuracy;

 num speed;

 num bearing;

////// num count;

 @JsonKey(name: "coord_type")
 */
     
    NSDictionary *dic = @{
        @"id":[[NSUUID UUID] UUIDString],
        @"time":@([self getDateTimeTOMilliSeconds:location.timestamp]),
        @"lat":@(location.coordinate.latitude),
        @"lon":@(location.coordinate.longitude),
        @"altitude":@(location.altitude),
        @"accuracy":@(location.horizontalAccuracy),
        @"vertical_accuracy":@(location.verticalAccuracy),
        @"speed":@(location.speed),
        @"bearing":@(location.course),
        @"coord_type":@"WGS84"//默认gps坐标
    };
    
    return [self convertJSONWithDic:dic];
}

//字典转JSON
- (NSString *)convertJSONWithDic:(NSDictionary *)dic {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        return @"字典转JSON出错";
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
 
//JSON转字典
+(NSDictionary *)convertDicWithJSON:(NSString *)jsonStr {
    if (jsonStr.length == 0) {
        return nil;
    }
    NSError *err;
    NSData *jsondata = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return nil;
    }
    
    return dic;
}
- (NSTimeInterval)getSecondsFromStarTime:(NSDate *)starTime andInsertEndTime:(NSDate *)endTime {
    
    NSDate* startDate = starTime;
    NSDate* endDate = endTime;
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    return time;
}

- (long long)getDateTimeTOMilliSeconds:(NSDate *)datetime
{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return totalMilliseconds;
}

@end
