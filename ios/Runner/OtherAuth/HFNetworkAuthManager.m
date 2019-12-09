//
//  HFNetworkAuthManager.m
//  Runner
//
//  Created by HF on 2019/12/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "HFNetworkAuthManager.h"
#import <UIKit/UIKit.h>
#import<CoreTelephony/CTCellularData.h>
#import "Reachability.h"


@implementation HFNetworkAuthManager

+ (void)checkPictureReadAuthBlock:(void (^)(BOOL isSuccess))completionBlock
{
    
    CTCellularData *cellularData = [[CTCellularData alloc]init];
    //__weak CTCellularData *weakdata = cellularData;
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {//检测应用中是否有联网权限
        if (kCTCellularDataNotRestricted == state) {//权限都允许了
            completionBlock(true);
        } else {
            [self netRequest:nil];
            if (kCTCellularDataRestrictedStateUnknown ==  state) {//需要弹框
                if ([self reachAbilityNetworkstatus]) {//TODO:这里暂定有效
                    completionBlock(true);
                }
            } else if (kCTCellularDataRestricted == state) {
                if ([self reachAbilityNetworkstatus]) {
                    completionBlock(true);
                } else {
                    [self showGoSettingAlert];
                }
            }
        }
    };
}

+ (BOOL)reachAbilityNetworkstatus
{
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    if (NotReachable == netStatus) {
        return false;
    } else {
        return true;
    }
}

+ (void)showGoSettingAlert
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请去设置页面 打开网络访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    NSLog(@"点击了Cancel");
    [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];//当前app的设置页面
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
     
    [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:okAction];
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [[window rootViewController]   presentViewController:alertVC animated:YES completion:nil];
}

+ (void)netRequest:(void (^)(BOOL isSuccess))completionBlock
{
    //请求地址
    NSURL *url = [NSURL URLWithString:@"http://www.apple.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    //设置请求session
    NSURLSession *session = [NSURLSession sharedSession];
    //设置网络请求的返回接收器
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //none
        if (completionBlock)
        completionBlock(error.code == 0);
         
    }];
    //开始请求
    [dataTask resume];
}

@end
