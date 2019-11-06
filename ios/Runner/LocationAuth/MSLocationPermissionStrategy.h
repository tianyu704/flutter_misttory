//
//  Created by HF on 2019/11/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "MSPermissionStrategy.h"


@interface MSLocationPermissionStrategy : NSObject <MSPermissionStrategy, CLLocationManagerDelegate>
- (instancetype)initWithLocationManager;
@end
