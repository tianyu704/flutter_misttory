    //
    //  BlessLocationManager.m
    //  flutter_amap_location_plugin
    //
    //  Created by HF on 2019/9/28.
    //

#import "BlessLocationManager.h"

@interface BlessLocationManager  () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void(^success )(NSString *locationJsonString);
@property (nonatomic, copy) void(^onceSuccess )(NSString *locationJsonString);
@property (nonatomic, assign) CLLocationDistance distanceFilter;
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy;
@property(assign, nonatomic) double timeCycleNum;
    //
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, assign) BOOL isFristLoad;
@property (nonatomic, assign) BOOL isOnce;
@property (nonatomic, weak) NSTimer *timer;

@end

@implementation BlessLocationManager

- (instancetype)initWithFilter:(CLLocationDistance)filter accuracy:(CLLocationAccuracy)accuracy timeCycle:(double)timeCycle
{
    self = [super init];
    if (!self)  return nil;
    self.distanceFilter = filter;
    self.desiredAccuracy = accuracy;
    self.timeCycleNum = timeCycle > 0 ? timeCycle : 5;
    [self commonInit];
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (!self)  return nil;
    self.distanceFilter = kCLDistanceFilterNone;
    self.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.timeCycleNum = 30;//五秒一获取定位
    [self commonInit];
    return self;
}

- (void)startTime {
    __weak typeof(self) weakSelf = self;
    self.timer= [BlessLocationManager fir_scheduledTimerWithTimeInterval:self.timeCycleNum block:^(NSTimer * _Nonnull timer) {
        [weakSelf.locationManager startUpdatingLocation];
        NSLog(@"%@",[NSDate date]);
    } repeats:YES];
   // [self.timer fire];//立即执行
}

- (void)auth
{
    [self.locationManager requestAlwaysAuthorization];// 永久授权
    [self.locationManager requestWhenInUseAuthorization];//使用中授权
}

- (BOOL)locationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

- (void)commonInit
{
    self.isFristLoad = YES;
    self.locationManager=[[CLLocationManager alloc] init];
    [self auth];
    if ([self locationServicesEnabled]) {
        self.locationManager.delegate = self;
            //默认开启了授权
            //NSLog(@"请开启定位:设置 > 隐私 > 位置 > 定位服务");
        if (@available(iOS 9.0, *)) {
            [self.locationManager setAllowsBackgroundLocationUpdates:YES];
        } else {
                // Fallback on earlier versions
        }
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        self.locationManager.desiredAccuracy =  self.desiredAccuracy;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;//self.distanceFilter;
        [self.locationManager startUpdatingLocation];
        
        //支持被kill掉以后能够后台自动重启
        //后台自动唤醒
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self startTime];
    }
}


- (void)onceLocationWithSuccess:(void(^)(NSString *locationJsonString))onceSuccess
{
    self.onceSuccess = onceSuccess;
}

- (void)startLocationWithSuccess:(void(^)(NSString *locationJsonString))success
{
    self.success = success;
}

- (void)startOnce {
    self.isOnce = true;
    [self.locationManager startUpdatingLocation];
}

- (void)restart {
    [self startTime];
    [self.locationManager startMonitoringSignificantLocationChanges];
}
- (void)stop
{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - location manager delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (self.isFristLoad) {
        self.isFristLoad = NO;
        return ;
    }
    //获取当前最大精度坐标 数值最小
    CLLocation *myLocation = locations.firstObject;
    for (CLLocation *l in locations) {
        if (myLocation.horizontalAccuracy >= l.horizontalAccuracy) {
            myLocation = l;
        }
    }
    if (!self.lastLocation) {
        self.lastLocation = myLocation;
    }
    //更新历史最大精度坐标 数值最小
    if (self.lastLocation && self.lastLocation.horizontalAccuracy >= myLocation.horizontalAccuracy) {
        self.lastLocation = myLocation;
    }
    if (self.isOnce && self.onceSuccess) {
        NSString *jsonStr = [self getJsonStringWithLocation:myLocation];
        self.onceSuccess(jsonStr);
        self.isOnce = false;
    }
    if (self.success) {
        NSString *jsonStr = [self getJsonStringWithLocation:self.lastLocation];
        self.success(jsonStr);
    }
}

//不论是创建还是写入只需调用此段代码即可 如果文件未创建 会进行创建操作
- (void)writeToFileWithTxt:(NSString *)string{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized (self) {
            //获取沙盒路径
            NSArray *paths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            //获取文件路径
            NSString *theFilePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"testLogs.text"];
            //创建文件管理器
            NSFileManager *fileManager = [NSFileManager defaultManager];
            //如果文件不存在 创建文件
            if(![fileManager fileExistsAtPath:theFilePath]){
                NSString *str = @"日志开始记录\n";
                [str writeToFile:theFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
            NSLog(@"所写内容=%@",string);
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:theFilePath];
            [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
            NSData* stringData  = [[NSString stringWithFormat:@"%@\n",string] dataUsingEncoding:NSUTF8StringEncoding];
            [fileHandle writeData:stringData]; //追加写入数据
            [fileHandle closeFile];
        }
    });
}

- (NSString *)getJsonStringWithLocation:(CLLocation *)location
{
    return [self getJsonStringWithLocation:location isNewDate:false];
}

- (NSString *)getJsonStringWithLocation:(CLLocation *)location isNewDate:(BOOL)isNewDate
{
    /**
     
     String id;
     
     num time;
     
     num lat;
     
     num lon;
     
     num altitude;
     
     num accuracy;
     
     @JsonKey(name: "vertical_accuracy")
     num verticalAccuracy;
     
     num speed;
     
     num bearing;
     
     ////// num count;
     
     @JsonKey(name: "coord_type")
     */
    
    NSDictionary *dic = @{
        @"id":[[NSUUID UUID] UUIDString],
        @"time":@([self getDateTimeTOMilliSeconds:isNewDate ? [NSDate date]:location.timestamp]),
        @"lat":@(location.coordinate.latitude),
        @"lon":@(location.coordinate.longitude),
        @"altitude":@(location.altitude),
        @"accuracy":@(location.horizontalAccuracy),
        @"vertical_accuracy":@(location.verticalAccuracy),
        @"speed":@(location.speed),
        @"bearing":@(location.course),
        @"coord_type":@"WGS84"//默认gps坐标
    };
    
    return [self convertJSONWithDic:dic];
}

    //字典转JSON
- (NSString *)convertJSONWithDic:(NSDictionary *)dic {
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        return @"字典转JSON出错";
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

    //JSON转字典
+(NSDictionary *)convertDicWithJSON:(NSString *)jsonStr {
    if (jsonStr.length == 0) {
        return nil;
    }
    NSError *err;
    NSData *jsondata = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return nil;
    }
    
    return dic;
}
- (NSTimeInterval)getSecondsFromStarTime:(NSDate *)starTime andInsertEndTime:(NSDate *)endTime {
    
    NSDate* startDate = starTime;
    NSDate* endDate = endTime;
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    return time;
}

- (long long)getDateTimeTOMilliSeconds:(NSDate *)datetime
{
    NSTimeInterval interval = [datetime timeIntervalSince1970];
    long long totalMilliseconds = interval*1000 ;
    return totalMilliseconds;
}

+ (void)_yy_ExecBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
        block(timer);
    }
}

+ (NSTimer *)fir_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(_yy_ExecBlock:) userInfo:[block copy] repeats:repeats];
}

@end

