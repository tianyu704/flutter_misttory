//
//  HFBlessLocationHelper.h
//  Runner
//
//  Created by HF on 2019/11/27.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFBlessLocationHelper : NSObject

- (void)startLocationWithSuccess:(void(^)(id sender))success;

- (void)restart;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
