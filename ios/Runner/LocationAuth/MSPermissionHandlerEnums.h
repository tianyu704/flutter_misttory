//
//  MSPermissionHandlerEnums.h
//  mspermission_handler
//
//  Created by HF on 2019/11/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//
typedef NS_ENUM(int, MSPermissionGroup) {
    MSPermissionGroupLocation,         //单次
    MSPermissionGroupLocationAlways,   //永久
    MSPermissionGroupLocationWhenInUse,//使用中
    MSPermissionGroupUnknown,
};

typedef NS_ENUM(int, MSPermissionStatus) {
    MSPermissionStatusDenied = 0,
    MSPermissionStatusDisabled,
    MSPermissionStatusGranted,//同意授权🤝
    MSPermissionStatusRestricted,
    MSPermissionStatusUnknown,
};

typedef NS_ENUM(int, MSServiceStatus) {
    MSServiceStatusDisabled = 0,
    MSServiceStatusEnabled,
    MSServiceStatusNotApplicable,
    MSServiceStatusUnknown,
};
