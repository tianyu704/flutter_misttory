//
//  TencentLocationManager.h
//  Runner
//
//  Created by HF on 2019/11/27.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TencentLocationManager : NSObject

/**
 是否能够进行定位
 */
@property (nonatomic, readonly) BOOL locationServicesEnabled;

/**
 是否获取了用户定位授权
 */
@property (nonatomic, readonly) BOOL locationAuth;

@property(assign, nonatomic) NSString *tencentKey;
/**
 用户没移动多少米，定位一次,单位是米 default:1000米
 */
@property(assign, nonatomic) CLLocationDistance distanceFilter;

/**
 定位精准度, default kCLLocationAccuracyBest
 */
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy;

/**
 循环定位时间
 */
@property(assign, nonatomic) NSInteger cycleTimerSeconds;

- (void)configLocationManager;
- (void)restart;
- (void)stop;

- (NSString *)getCurrentLocationString;
- (void)clearCurrentLocation;
- (void)startLocationWithSuccess:(void(^)(NSString *locationJsonString))success;
- (void)onceLocationWithSuccess:(void(^)(NSString *locationJsonString))onceSuccess;

@end

NS_ASSUME_NONNULL_END
