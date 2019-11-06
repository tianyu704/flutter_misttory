//
//  MSPermissionManager.h
//  mspermission_handler
//
//  Created by HF on 2019/11/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MSLocationPermissionStrategy.h"
#import "MSPermissionStrategy.h"
#import "MSPermissionHandlerEnums.h"
 

typedef void (^MSPermissionRequestCompletion)(NSDictionary *permissionRequestResults);

@interface MSPermissionManager : NSObject

- (instancetype)initWithStrategyInstances;

+ (MSPermissionStatus)getPermissionStatus:(enum MSPermissionGroup)permission;

//+ (void)checkPermissionStatus:(enum MSPermissionGroup)permission result:(FlutterResult)result;

//+ (void)checkServiceStatus:(enum PermissionGroup)permission result:(FlutterResult)result;

+ (void)openAppSettings:(FlutterResult)result;

- (void)requestPermissions:(NSArray *)permissions completion:(MSPermissionRequestCompletion)completion;



@end
