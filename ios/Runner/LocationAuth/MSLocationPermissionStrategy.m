//
//  Created by HF on 2019/11/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "MSLocationPermissionStrategy.h"


@implementation MSLocationPermissionStrategy {
    CLLocationManager *_locationManager;
    MSPermissionStatusHandler _permissionStatusHandler;
    MSPermissionGroup _requestedPermission;
}

- (instancetype)initWithLocationManager {
    self = [super init];
    if (self) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    
    return self;
}

- (MSPermissionStatus)checkPermissionStatus:(MSPermissionGroup)permission {
    return [MSLocationPermissionStrategy permissionStatus:permission];
}

- (MSServiceStatus)checkServiceStatus:(MSPermissionGroup)permission {
    return [CLLocationManager locationServicesEnabled] ? MSServiceStatusEnabled : MSServiceStatusDisabled;
}

- (void)requestPermission:(MSPermissionGroup)permission completionHandler:(MSPermissionStatusHandler)completionHandler {
    MSPermissionStatus status = [self checkPermissionStatus:permission];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse && permission == MSPermissionGroupLocationAlways) {
        // don't do anything and continue requesting permissions
    } else if (status != MSPermissionStatusUnknown) {
        completionHandler(status);
    }
    
    _permissionStatusHandler = completionHandler;
    _requestedPermission = permission;
    
    if (permission == MSPermissionGroupLocation) {
        if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil) {
            [_locationManager requestAlwaysAuthorization];
        } else if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil) {
            [_locationManager requestWhenInUseAuthorization];
        } else {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"To use location in iOS8 you need to define either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription in the app bundle's Info.plist file" userInfo:nil] raise];
        }
    } else if (permission == MSPermissionGroupLocationAlways) {
        if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil) {
            [_locationManager requestAlwaysAuthorization];
        } else {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"To use location in iOS8 you need to define NSLocationAlwaysUsageDescription in the app bundle's Info.plist file" userInfo:nil] raise];
        }
    } else if (permission == MSPermissionGroupLocationWhenInUse) {
        if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil) {
            [_locationManager requestWhenInUseAuthorization];
        } else {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"To use location in iOS8 you need to define NSLocationWhenInUseUsageDescription in the app bundle's Info.plist file" userInfo:nil] raise];
        }
    }
}

// {WARNING}
// This is called when the location manager is first initialized and raises the following situations:
// 1. When we first request [PermissionGroupLocationWhenInUse] and then [PermissionGroupLocationAlways]
//    this will be called when the [CLLocationManager] is first initialized with
//    [kCLAuthorizationStatusAuthorizedWhenInUse]. As a consequence we send back the result to early.
// 2. When we first request [PermissionGroupLocationWhenInUse] and then [PermissionGroupLocationAlways]
//    and the user doesn't allow for [kCLAuthorizationStatusAuthorizedAlways] this method is not called
//    at all.
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) {
        return;
    }
    
    if (_permissionStatusHandler == nil || @(_requestedPermission) == nil) {
        return;
    }
    
    MSPermissionStatus permissionStatus = [MSLocationPermissionStrategy
                                         determinePermissionStatus:_requestedPermission authorizationStatus:status];
    
    _permissionStatusHandler(permissionStatus);
}


+ (MSPermissionStatus)permissionStatus:(MSPermissionGroup)permission {
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    
    
    MSPermissionStatus status = [MSLocationPermissionStrategy
                               determinePermissionStatus:permission authorizationStatus:authorizationStatus];
    
    if ((status == MSPermissionStatusGranted || status == MSPermissionStatusDenied)
        && ![CLLocationManager locationServicesEnabled]) {
        return MSPermissionStatusDisabled;
    }
    
    return status;
}


+ (MSPermissionStatus)determinePermissionStatus:(MSPermissionGroup)permission authorizationStatus:(CLAuthorizationStatus)authorizationStatus {
    if (@available(iOS 8.0, *)) {
        if (permission == MSPermissionGroupLocationAlways) {
            switch (authorizationStatus) {
                case kCLAuthorizationStatusNotDetermined:
                    return MSPermissionStatusUnknown;
                case kCLAuthorizationStatusRestricted:
                    return MSPermissionStatusRestricted;
                case kCLAuthorizationStatusDenied:
                case kCLAuthorizationStatusAuthorizedWhenInUse:
                    return MSPermissionStatusDenied;
                case kCLAuthorizationStatusAuthorizedAlways:
                    return MSPermissionStatusGranted;
            }
        }
        
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                return MSPermissionStatusUnknown;
            case kCLAuthorizationStatusRestricted:
                return MSPermissionStatusRestricted;
            case kCLAuthorizationStatusDenied:
                return MSPermissionStatusDenied;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                return MSPermissionStatusGranted;
        }
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    switch (authorizationStatus) {
        case kCLAuthorizationStatusNotDetermined:
            return MSPermissionStatusUnknown;
        case kCLAuthorizationStatusRestricted:
            return MSPermissionStatusRestricted;
        case kCLAuthorizationStatusDenied:
            return MSPermissionStatusDenied;
        case kCLAuthorizationStatusAuthorized:
            return MSPermissionStatusGranted;
        default:
            return MSPermissionStatusUnknown;
    }

#pragma clang diagnostic pop

}

@end
