//
//  BlessLocationManager.h
//  flutter_amap_location_plugin
//
//  Created by HF on 2019/9/28.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlessLocationManager : NSObject

- (instancetype)initWithFilter:(CLLocationDistance)filter accuracy:(CLLocationAccuracy)accuracy timeCycle:(double)timeCycle;

- (void)startLocationWithSuccess:(void(^)(NSString *locationJsonString))success;
- (void)onceLocationWithSuccess:(void(^)(NSString *locationJsonString))onceSuccess;

- (void)startOnce;
- (void)restart;
- (void)stop;


- (void)writeToFileWithTxt:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
