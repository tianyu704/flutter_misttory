//
//  BlessLocationHelper.h
//  flutter_amap_location_plugin
//
//  Created by HF on 2019/9/28.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlessLocationHelper : NSObject

- (instancetype)initWithFilter:(CLLocationDistance)filter accuracy:(CLLocationAccuracy)accuracy;

- (void)startLocationWithSuccess:(void(^)(CLLocation *))success;

@end

NS_ASSUME_NONNULL_END
