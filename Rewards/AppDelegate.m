//
//  AppDelegate.m
//  Rewards
//
//  Created by Chang Liu on 2012-09-29.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "AppDelegate.h"
#import "RewardsViewController.h"
#import <Parse/Parse.h>
#import "ScanViewController.h"
#import "PointRewardsViewController.h"
#import "AccountViewController.h"
#import "HelpViewController.h"
#import "Flurry.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"ZU1qV0453AatIvaV2lYD1DgwvLZ1UPHA8zhQ9mSD" clientKey:@"VupiJigC5X3DwpavzcQNK8IKDlEL03IE9UwHgUcV"];
    [Flurry startSession:@"XTMKDSXVZY8RDR5K3SV3"];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [Flurry setSessionReportsOnPauseEnabled:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // Override point for customization after application launch.
    ScanViewController *viewController1 = [[[ScanViewController alloc] initWithNibName:@"ScanViewController" bundle:nil] autorelease];
    RewardsViewController *viewController2 = [[[RewardsViewController alloc] initWithNibName:@"RewardsViewController" bundle:nil] autorelease];
    PointRewardsViewController *viewController3 = [[[PointRewardsViewController alloc] initWithNibName:@"PointRewardsViewController" bundle:nil] autorelease];
    AccountViewController *viewController4 = [[[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil] autorelease];
    HelpViewController *viewController5 = [[[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil] autorelease];
    
    self.tabBarController = [[[RewardCatTabBarController alloc] init] autorelease];
    if ([self.tabBarController.tabBar respondsToSelector:@selector(selectedImageTintColor)]) {
        self.tabBarController.tabBar.selectedImageTintColor = [UIColor greenColor];
    }
    self.tabBarController.viewControllers = @[viewController1, viewController2, viewController3, viewController4, viewController5];
    
    viewController1.tabBarController = self.tabBarController;
    self.window.rootViewController = self.tabBarController;
    
    [Flurry logAllPageViews:self.tabBarController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

void uncaughtExceptionHandler(NSException *exception)
{
    [Flurry logError:@"Uncaught"
             message:@"Crash!"
           exception:exception];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
