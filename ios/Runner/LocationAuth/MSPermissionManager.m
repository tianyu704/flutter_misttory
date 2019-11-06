//
//  Created by HF on 2019/11/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "MSPermissionManager.h"

@implementation MSPermissionManager {
    NSMutableArray <id <MSPermissionStrategy>> *_strategyInstances;
}

- (instancetype)initWithStrategyInstances {
    self = [super init];
    if (self) {
        _strategyInstances = _strategyInstances = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (MSPermissionStatus)getPermissionStatus:(enum MSPermissionGroup)permission
{
    id <MSPermissionStrategy> permissionStrategy = [MSPermissionManager createPermissionStrategy:permission];
    MSPermissionStatus status = [permissionStrategy checkPermissionStatus:permission];
    return status;
}
+ (void)checkPermissionStatus:(enum MSPermissionGroup)permission result:(FlutterResult)result {
    MSPermissionStatus status =  [self getPermissionStatus:permission];
    NSString *resultStr = MSPermissionStatusGranted == status ? @"GRANTED" :@"DENIED";
    result(resultStr);
}

//+ (void)checkServiceStatus:(enum MSPermissionGroup)permission result:(FlutterResult)result {
//    id <MSPermissionStrategy> permissionStrategy = [PermissionManager createPermissionStrategy:permission];
//    ServiceStatus status = [permissionStrategy checkServiceStatus:permission];
//    result([Codec encodeServiceStatus:status]);
//}

- (void)requestPermissions:(NSArray *)permissions completion:(MSPermissionRequestCompletion)completion {
    NSMutableSet *requestQueue = [[NSMutableSet alloc] initWithArray:permissions];
    NSMutableDictionary *permissionStatusResult = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < permissions.count; ++i) {
        MSPermissionGroup value;
        [permissions[i] getValue:&value];
        MSPermissionGroup permission = value;
        
        id <MSPermissionStrategy> permissionStrategy = [MSPermissionManager createPermissionStrategy:permission];
        [_strategyInstances addObject:permissionStrategy];
        
        
        [permissionStrategy requestPermission:permission completionHandler:^(MSPermissionStatus permissionStatus) {
            permissionStatusResult[@(permission)] = @(permissionStatus);
            [requestQueue removeObject:@(permission)];
            
            [self->_strategyInstances removeObject:permissionStrategy];
            
            if (requestQueue.count == 0) {
                completion(permissionStatusResult);
                return;
            }
        }];
    }
}

+ (void)openAppSettings:(FlutterResult)result {
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:[[NSDictionary alloc] init]
                                 completionHandler:^(BOOL success) {
                                     result([[NSNumber alloc] initWithBool:success]);
                                 }];
    } else if (@available(iOS 8.0, *)) {
        BOOL success = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        result([[NSNumber alloc] initWithBool:success]);
    } else {
        result(@false);
    }
}

+ (id)createPermissionStrategy:(MSPermissionGroup)permission {
    return [[MSLocationPermissionStrategy alloc] initWithLocationManager];
}

@end
