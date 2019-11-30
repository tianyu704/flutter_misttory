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
#import "Runner-Bridging-Header.h"
#import "Runner-Swift.h"

FlutterMethodChannel *_channel;
HFArcManager *arcManager;
NSDate *lastDate;
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
            if ([@"init" isEqualToString:call.method]) {
                arcManager = [[HFArcManager alloc]init];
                result(@YES);
            } else if ([@"start_location" isEqualToString:call.method]) {
                if (call.arguments) {
                    arcManager = [[HFArcManager alloc]init]; true;//允许使用全天记录省电模式
                   
                    NSDictionary *params = call.arguments;
                    double num = [params[@"interval"]doubleValue];//单次定位间隔时间毫秒
                    num = num/1000;//转second
                    arcManager.timeCycleNum = num / 2;
                }
                [arcManager arcStart];
                 arcManager.myEidtorBlock = ^(CLLocation *lo) {
                     BOOL isWrite = true;
                     if (lastDate) {
                         long time = [self getSecondsFromStarTime:lastDate andInsertEndTime:[NSDate date]];
                         if (time <  arcManager.timeCycleNum) {
                             isWrite = false;
                         }
                     }
                     if (isWrite) {
                         lastDate = [NSDate date];
                         NSString *locationJsonString = [self getJsonStringWithLocation:lo];
                         [_channel invokeMethod:@"locationListener" arguments:locationJsonString];
                     }
                };
       
            } else if ([@"current_location" isEqualToString:call.method]) {//获取一次定位
                
                CLLocation *once =  [arcManager arcOnce];
                if (once) {
                    NSString *json = [self getJsonStringWithLocation:once];
                    result(json);
                } else {
                    
                }
            } else if ([@"stop_location" isEqualToString:call.method]) {
                [arcManager arcStop];
                result(@"停止定位");
            } else if ([@"destroy" isEqualToString:call.method]) {
               [arcManager arcStop];
                result(@"销毁（停止定位）");
            } else {
                result(FlutterMethodNotImplemented);
            }
        }
    }];
}


+ (NSString *)getJsonStringWithLocation:(CLLocation *)location
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
+ (NSString *)convertJSONWithDic:(NSDictionary *)dic {
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
+ (NSTimeInterval)getSecondsFromStarTime:(NSDate *)starTime andInsertEndTime:(NSDate *)endTime {
    
    NSDate* startDate = starTime;
    NSDate* endDate = endTime;
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    return time;
}

+ (long long)getDateTimeTOMilliSeconds:(NSDate *)datetime
{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return totalMilliseconds;
}
 
@end
