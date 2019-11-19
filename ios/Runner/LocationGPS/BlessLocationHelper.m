//
//  BlessLocationHelper.m
//  flutter_amap_location_plugin
//
//  Created by HF on 2019/9/28.
//

#import "BlessLocationHelper.h"
//#import <CoreLocation/CoreLocation.h>

@interface BlessLocationHelper  () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
 @property (nonatomic, copy) void(^success )(CLLocation *location);
@property (nonatomic, assign) CLLocationDistance distanceFilter;
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy;
//
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSDate *lastDate;

@end

@implementation BlessLocationHelper

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
    }
}

 

- (void)startLocationWithSuccess:(void(^)(CLLocation *))success
{
    self.success = success;
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
    if (self.success) {
        self.success(myLocation);
    }
}

- (NSTimeInterval)getSecondsFromStarTime:(NSDate *)starTime andInsertEndTime:(NSDate *)endTime {
    
    NSDate* startDate = starTime;
    NSDate* endDate = endTime;
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    return time;
}


@end
