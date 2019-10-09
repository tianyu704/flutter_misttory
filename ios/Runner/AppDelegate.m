#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
      /*********应用kill以后基站定位唤醒*************/
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        //NSLog(@"在后台被唤醒");
       // UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"应用kill以后基站定位唤醒" message:@"" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
      //  [alert show];
              // do something，这里就可以再次调用startUpdatingLocation，开启精确定位啦
    }
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
