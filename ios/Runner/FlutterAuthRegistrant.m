    //
    //  FlutterAuthRegistrant.m
    //  Runner
    //
    //  Created by HF on 2019/11/6.
    //  Copyright © 2019 The Chromium Authors. All rights reserved.
    //

#import "FlutterAuthRegistrant.h"
#import <Flutter/Flutter.h>
#import <CoreLocation/CoreLocation.h>
#import "MSPermissionManager.h"
#import "BlessLocationManager.h"
#include "AppDelegate.h"

FlutterMethodChannel *_channel;

@implementation FlutterAuthRegistrant

+ (void)authRegistrant:(id)vc
{
    FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"com.admqr.misstory"
                                            binaryMessenger:vc];
   _channel = batteryChannel;
    ///channel
    MSPermissionManager *manager = [[MSPermissionManager alloc]init];
    [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"request_location_permission" isEqualToString:call.method]) {
            //请求授权
            [manager requestPermissions:@[@(MSPermissionGroupLocationAlways)] completion:^(NSDictionary *permissionRequestResults) {
                //判断授权
                BOOL isFlag =  MSPermissionStatusGranted == [MSPermissionManager getPermissionStatus:MSPermissionGroupLocationAlways];
                BOOL isFlag1 =  MSPermissionStatusGranted == [MSPermissionManager getPermissionStatus:MSPermissionGroupLocationWhenInUse];
                if (isFlag || isFlag1) {
                    result(@"GRANTED");
                } else {
                    result(@"DENIED");
                }
            }];
            return ;
        } else {
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if ([@"start_location" isEqualToString:call.method]) {
                if (call.arguments) {
                    
                    NSDictionary *params = call.arguments;
                    double num = [params[@"interval"]doubleValue];//单次定位间隔时间毫秒
                    num = num/1000;//转second
//                    double desiredAccuracy = [params[@"locationMode"] doubleValue];
                    double distanceFilter = [params[@"distanceFilter"]doubleValue];//每间隔distanceFilter 米定位一次
                    app.blessManager  = [[BlessLocationManager alloc]initWithFilter:distanceFilter accuracy:kCLLocationAccuracyNearestTenMeters timeCycle:num / 2];
                } else {
                    app.blessManager = [[BlessLocationManager alloc]init];
                }
                [app.blessManager startLocationWithSuccess:^(NSString * _Nonnull locationJsonString) {
                    [_channel invokeMethod:@"locationListener" arguments:locationJsonString];
                }];
            } else if ([@"current_location" isEqualToString:call.method]) {//获取一次定位
                [app.blessManager onceLocationWithSuccess:^(NSString * _Nonnull locationJsonString) {
                    result(locationJsonString);
                }];
            } else if ([@"stop_location" isEqualToString:call.method]) {
                [app.blessManager stop];
                result(@"停止定位");
            } else if ([@"destroy" isEqualToString:call.method]) {
                [app.blessManager stop];
                result(@"销毁（停止定位）");
            } else {
                result(FlutterMethodNotImplemented);
            }
        }
    }];
}


@end
