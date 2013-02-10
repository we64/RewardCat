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
#import "GameUtils.h"
#import "LocationManager.h"
#import "Reachability.h"

@implementation AppDelegate

@synthesize connected;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Parse Prod
    [Parse setApplicationId:@"ZU1qV0453AatIvaV2lYD1DgwvLZ1UPHA8zhQ9mSD" clientKey:@"VupiJigC5X3DwpavzcQNK8IKDlEL03IE9UwHgUcV"];
    
    // Parse Dev
    //[Parse setApplicationId:@"Lw85NFZvjs7L2yGzSpdUDeimKKpIv1xKdpayewza" clientKey:@"MOhIoElZG3UDhhdJAfE81BJf3tNB5eiUutBUtq4m"];
    
    // Flurry Prod
    [Flurry startSession:@"XTMKDSXVZY8RDR5K3SV3"];
    
    // Flurry Dev
    //[Flurry startSession:@"7J7DYNJS748WZG9R5VW7"];
    
    [PFFacebookUtils initializeWithApplicationId:@"497689073585333"];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [Flurry setSessionReportsOnPauseEnabled:YES];
    
    [Flurry logEvent:@"action_app_launch"];

    // get all vendor objects and store in cache
    if ([self checkConnectivity]) {
        [PFQuery clearAllCachedResults];
        PFQuery *queryVendor = [PFQuery queryWithClassName:@"Vendor"];
        NSArray *allVendors = [queryVendor findObjects];
        [allVendors enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            PFObject *vendor = object;
            [[GameUtils instance].vendorDictionary setObject:vendor forKey:vendor.objectId];
        }];
    }

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
    self.connected = NO;
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    // add 3 days
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit )
                                                   fromDate:[[NSDate date] dateByAddingTimeInterval:60*60*72]];
    // 11:30 every morning
    [dateComponents setHour:11];
    [dateComponents setMinute:30];
    [dateComponents setSecond:0];
    
    notif.fireDate = [calendar dateFromComponents:dateComponents];
    notif.timeZone = [NSTimeZone defaultTimeZone];

    NSString *message;
    PFUser *user = [PFUser currentUser];
    NSString *deviceUUID = [user objectForKey:@"uuid"];
    if (![deviceUUID isEqualToString:user.username] &&
        [((NSNumber *)[user objectForKey:@"rewardcatPoints"]) intValue] >= 10) {
        message = @"RewardCat says you have rewards to redeem *meow*! Visit the Coins tab to see what they are.";
    } else if ([deviceUUID isEqualToString:user.username]) {
        message = @"Want to redeem rewards *meow*? Signup on RewardCat, and get enough Coins to start redeeming.";
    } else {
        message = @"Getting rewarded is great! Keep using RewardCat to get more rewards!";
    }

    notif.alertBody = message;
    notif.alertAction = @"Get Rewards";
    notif.soundName = UILocalNotificationDefaultSoundName;
    notif.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    [notif release];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Flurry logEvent:@"action_app_enter_from_background"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    // check to see if location service is available
    // start updating current location
    if ([LocationManager allowLocationService]) {
        [[LocationManager sharedSingleton] startUpdatingLocation];
    }
    
    // cehck connectivity
    if ([self checkConnectivity]) {
        [Flurry logEvent:@"connectivity_on_app_start_yes"];
        
        // get all vendor objects and store in cache
        PFQuery *queryVendor = [PFQuery queryWithClassName:@"Vendor"];
        [queryVendor findObjectsInBackgroundWithBlock:^(NSArray *allVendors, NSError *error) {
            [allVendors enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
                PFObject *vendor = object;
                [[GameUtils instance].vendorDictionary setObject:vendor forKey:vendor.objectId];
            }];
        }];
    } else {
        [Flurry logEvent:@"connectivity_on_app_start_no"];
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Internet Connection Error"
                                                         message:@"Please use RewardCat with internet connection."
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil] autorelease];
        [alert show];
    }
    
    if (self.window == nil) {
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
        viewController2.tabBarController = self.tabBarController;
        viewController3.tabBarController = self.tabBarController;
        viewController4.tabBarController = self.tabBarController;
        viewController5.tabBarController = self.tabBarController;
        self.window.rootViewController = self.tabBarController;
        
        [Flurry logAllPageViews:self.tabBarController];
        [self.window makeKeyAndVisible];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

void uncaughtExceptionHandler(NSException *exception)
{
    [Flurry logError:@"Uncaught"
             message:@"Crash!"
           exception:exception];
}

- (BOOL)checkConnectivity {
    if (!self.connected) {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [reachability currentReachabilityStatus];
        self.connected = !(networkStatus == NotReachable);
    }
    return self.connected;
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
