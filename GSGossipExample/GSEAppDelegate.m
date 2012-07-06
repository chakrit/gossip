//
//  GSEAppDelegate.m
//  GSGossipExample
//
//  Created by Chakrit Wichian on 7/6/12.
//

#import "GSEAppDelegate.h"
#import "GSERootViewController.h"

#import "GSConfiguration.h"
#import "GSUserAgent.h"


@implementation GSEAppDelegate {
    UIWindow *_window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // initialize view
    GSERootViewController *root = [[GSERootViewController alloc] init];
    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [_window setRootViewController:root];
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application { }
- (void)applicationDidEnterBackground:(UIApplication *)application { }
- (void)applicationWillEnterForeground:(UIApplication *)application { }
- (void)applicationDidBecomeActive:(UIApplication *)application { }
- (void)applicationWillTerminate:(UIApplication *)application { }

@end
