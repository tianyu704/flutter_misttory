//
//  HFBlessLocationHelper.m
//  Runner
//
//  Created by HF on 2019/11/27.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "HFBlessLocationHelper.h"
#import <CoreLocation/CoreLocation.h>

@interface HFBlessLocationHelper ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void(^success )(id sender);

@end

@implementation HFBlessLocationHelper

- (instancetype)init
{
    self = [super init];
    if (!self)  return nil;
    [self commonInit];
    return self;
}

- (void)commonInit
{
    self.locationManager=[[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //默认开启了授权
    //NSLog(@"请开启定位:设置 > 隐私 > 位置 > 定位服务");
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization]; // 永久授权
        [self.locationManager requestWhenInUseAuthorization]; //使用中授权
    }
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    //支持被kill掉以后能够后台自动重启
    //后台自动唤醒
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)startLocationWithSuccess:(void(^)(id sender))success
{
    self.success = success;
}

- (void)restart
{
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stop
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

#pragma mark - location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (self.success) {
        self.success(@"");
    }
}

@end
