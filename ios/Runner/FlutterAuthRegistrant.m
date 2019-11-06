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
@implementation FlutterAuthRegistrant

+ (void)authRegistrant:(id)vc
{
    FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"com.admqr.misstory"
                                            binaryMessenger:vc];
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
        }
    }];
}


@end
