//
//  AppDelegate.m
//  TestValidateApp
//
//  Created by tungngo on 26/6/25.
//

#import "AppDelegate.h"
#import "TestValidateApp-Swift.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    DownloaderVC *rootVC = [[DownloaderVC alloc] initWithNibName:@"DownloaderVC" bundle:nil];

    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
    return YES;
}


#pragma mark - UISceneSession lifecycle


@end
