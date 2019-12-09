#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "FlutterAuthRegistrant.h"
 

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
  [FlutterAuthRegistrant authRegistrant:controller];
  // Override point for customization after application launch.
      /*********应用kill以后基站定位唤醒*************/
  if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
      [self.blessManager writeToFileWithTxt:@"############start****\n"];
         [self.blessManager writeToFileWithTxt:@"程序在后台被唤醒了🛌🛌🛌🛌🛌🛌🛌🛌🛌🛌"];
         [self.blessManager writeToFileWithTxt:@"############end*********\n"];
        //NSLog(@"在后台被唤醒");
       // UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"应用kill以后基站定位唤醒" message:@"" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
      //  [alert show];
              // do something，这里就可以再次调用startUpdatingLocation，开启精确定位啦
  }
  NSLog(@"%@",[self documentsDir]);
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


- (NSString *)documentsDir {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}


// 当你的程序将要被挂起，会调用改方法
- (void)applicationWillResignActive:(UIApplication *)application {
    /** 应用进入后台执行定位 保证进程不被系统kill */
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self.blessManager restart];
}

/** 应用进入后台执行定位 保证进程不被系统kill */
- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIApplication *app = [UIApplication sharedApplication];
    __block  UIBackgroundTaskIdentifier bgTask  = 0;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            if (bgTask != UIBackgroundTaskInvalid){
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid){
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
    // 实现如下代码，才能使程序处于后台时被杀死，调用applicationWillTerminate:方法
    //[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){}];
    [self.blessManager restart];
    
}
 
- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"程序被杀死，applicationWillTerminate");
    [self.blessManager writeToFileWithTxt:@"############start****\n"];
    [self.blessManager writeToFileWithTxt:@"程序被杀死，applicationWillTerminate⚠️🈲🈲🈲🈲🈲🈲🈲"];
    [self.blessManager writeToFileWithTxt:@"############end*********\n"];
}
 

@end
