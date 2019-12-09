//
//  HFPictureAuthManager.m
//  Runner
//
//  Created by HF on 2019/12/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "HFPictureAuthManager.h"
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

@implementation HFPictureAuthManager

+ (void)checkPictureReadAuthBlock:(void (^)(BOOL isSuccess))completionBlock
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (PHAuthorizationStatusAuthorized == status) {// 用户允许访问相册
        completionBlock(true);
    } else {
        if (status == PHAuthorizationStatusNotDetermined) { //用户还没做出选择
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) { // 用户点击了好
                  // 放一些使用相册的代码
                    completionBlock(true);
                } else {//到设置中打开开关
                    [self showGoSettingAlert];
                }
            }];
        } else {//到设置中打开开关
            [self showGoSettingAlert];
        }
    }
}

+ (void)showGoSettingAlert
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请去设置页面 打开照片访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
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

@end
