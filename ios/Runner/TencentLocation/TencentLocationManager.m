//
//  TencentLocationManager.m
//  Runner
//
//  Created by HF on 2019/11/27.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "TencentLocationManager.h"
#import <TencentLBS/TencentLBS.h>
#import "HFBlessLocationHelper.h"

@interface TencentLocationManager () <TencentLBSLocationManagerDelegate>

@property (nonatomic, strong) TencentLBSLocationManager *locationManager;
@property (nonatomic, strong) HFBlessLocationHelper *locationHelper;
@property (nonatomic, readwrite) BOOL locationAuth;
@property (nonatomic, copy) void(^success )(NSString *locationJsonString);
@property (nonatomic, copy) void(^onceSuccess )(NSString *locationJsonString);
//@property (nonatomic, copy) void(^success )(TencentLocationManager *manager,NSString *locationJsonString);
//@property (nonatomic, copy) void(^failure)(TencentLocationManager *manager);
///
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, assign) BOOL isFristLoad;

@end

@implementation TencentLocationManager

- (instancetype)init
{
    self = [super init];
    if (!self)  return nil;
    
    self.locationAuth = YES;
    self.distanceFilter = 200;
    self.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.cycleTimerSeconds = 30;
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

- (void)configLocationManager
{
    [self auth];
    if ([self locationServicesEnabled]) {
        self.locationManager = [[TencentLBSLocationManager alloc] init];
        [self.locationManager setPausesLocationUpdatesAutomatically:NO];
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        [self.locationManager setApiKey:(self.tencentKey && self.tencentKey.length > 0) ? self.tencentKey : @"24DBZ-IJFC4-YSYUQ-D2NAI-LYXDO-4HFUV"];
        [self.locationManager setCoordinateType:TencentLBSLocationCoordinateTypeWGS84];//默认返回坐标为WGS84坐标
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        self.locationManager.desiredAccuracy =  self.desiredAccuracy;
        self.locationManager.distanceFilter = self.distanceFilter;
        [self.locationManager setDelegate:self];
        /////
        __weak typeof(self) weakSelf = self;
        self.locationHelper = nil;
        self.locationHelper = [[HFBlessLocationHelper alloc]init];
        [self.locationHelper startLocationWithSuccess:^(id  _Nonnull sender) {
            [weakSelf restart];
        }];
        //[self restart];防止打开两遍
    }
}

- (void)onceLocationWithSuccess:(void(^)(NSString *locationJsonString))onceSuccess
{
    self.onceSuccess = onceSuccess;
}

- (void)startLocationWithSuccess:(void(^)(NSString *locationJsonString))success
{
    self.success = success;
}

- (void)restart
{
    [self.locationManager startUpdatingLocation];
}

- (void)stop
{
    [self.locationManager stopUpdatingLocation];
    [self.locationHelper stop];
}

- (NSString *)getCurrentLocationString
{
    return [self getJsonStringWithLocation:self.currentLocation];
}

- (void)clearCurrentLocation
{
    self.currentLocation = nil;
}

#pragma mark - TencentLBSLocationManagerDelegate

- (void)tencentLBSLocationManager:(TencentLBSLocationManager *)manager didUpdateLocation:(TencentLBSLocation *)location
{
    bool isWright = YES;
    if (self.lastDate) {
        long t = [self getSecondsFromStarTime:self.lastDate andInsertEndTime:[NSDate date]];
        if (t < self.cycleTimerSeconds) {
            isWright = NO;
            //NSLog(@"时间太短了 %@ < %@不记录",@(t),@(self.timeCycleNum));
        }
    }
    CLLocation *myLocation = location.location;
    //更新历史最大精度坐标 数值最小
    if (!self.lastLocation || (self.lastLocation && self.lastLocation.horizontalAccuracy >= myLocation.horizontalAccuracy)) {
        self.lastLocation = myLocation;
    }
    self.currentLocation = myLocation;
    if (self.onceSuccess) {
        NSString *jsonStr = [self getJsonStringWithLocation:myLocation];
        self.onceSuccess(jsonStr);
        self.onceSuccess = nil;
    }
    if (isWright) {
        self.lastDate = [NSDate date];
        if (self.success) {
            NSString *jsonStr = [self getJsonStringWithLocation:self.lastLocation];
            self.success(jsonStr);
        }
        self.lastLocation = nil;
    }
//    if (self.lastLocation) {
//        double distance = [myLocation distanceFromLocation:self.lastLocation];
//        if (distance < 2) {
//            NSLog(@"太近了 不记录");
//                // return;
//        }
//        NSLog(@"%@======",@(distance));
//    }
    
       
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
