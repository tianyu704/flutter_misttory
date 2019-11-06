//
//  Created by HF on 2019/11/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSPermissionHandlerEnums.h"

typedef void (^MSPermissionStatusHandler)(MSPermissionStatus permissionStatus);

@protocol MSPermissionStrategy <NSObject>
- (MSPermissionStatus)checkPermissionStatus:(MSPermissionGroup)permission;

- (MSServiceStatus)checkServiceStatus:(MSPermissionGroup)permission;

- (void)requestPermission:(MSPermissionGroup)permission completionHandler:(MSPermissionStatusHandler)completionHandler;
@end
