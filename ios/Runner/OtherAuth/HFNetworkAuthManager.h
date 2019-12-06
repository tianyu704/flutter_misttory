//
//  HFNetworkAuthManager.h
//  Runner
//
//  Created by HF on 2019/12/6.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFNetworkAuthManager : NSObject

+ (void)checkPictureReadAuthBlock:(void (^)(BOOL isSuccess))completionBlock;

@end

NS_ASSUME_NONNULL_END
