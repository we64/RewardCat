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
#import "DiscountsViewController.h"
#import "GameUtils.h"
#import "LocationManager.h"
#import "AdsUtils.h"
#import "Reachability.h"
#import <FacebookSDK/FacebookSDK.h>

#define kAlertViewOne 1
#define kAlertViewBonusCoins 2

@implementation AppDelegate

@synthesize connected;
@synthesize noNetworkAlertView;

- (void)dealloc
{
    [_window release]; _window = nil;
    [_tabBarController release]; _tabBarController = nil;
    [noNetworkAlertView release]; noNetworkAlertView = nil;
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Parse Prod
    //[Parse setApplicationId:@"ZU1qV0453AatIvaV2lYD1DgwvLZ1UPHA8zhQ9mSD" clientKey:@"VupiJigC5X3DwpavzcQNK8IKDlEL03IE9UwHgUcV"];
    
    // Parse Dev
    [Parse setApplicationId:@"Lw85NFZvjs7L2yGzSpdUDeimKKpIv1xKdpayewza" clientKey:@"MOhIoElZG3UDhhdJAfE81BJf3tNB5eiUutBUtq4m"];

    [PFFacebookUtils initializeFacebook];

    // get all vendor objects and store in cache
    if ([self checkConnectivity]) {
        [PFQuery clearAllCachedResults];
    }

    // Handle launching from a notification
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        [self showNotificationView:localNotif];
    }

    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notification {
    [self showNotificationView:notification];
}

- (void)showNotificationView:(UILocalNotification *)notification {
    if (notification.userInfo) {
        NSNumber *coins = [notification.userInfo objectForKey:@"coinReward"];
        
        // save
        [[PFUser currentUser] incrementKey:@"rewardcatPoints" byAmount:coins];
        PFObject *transaction = [PFObject objectWithClassName:@"Transaction"];
        [transaction setObject:@"Bonus Coins" forKey:@"activityType"];
        [transaction setObject:coins forKey:@"rewardcatPointsDelta"];
        [transaction setObject:[PFUser currentUser] forKey:@"user"];
        NSArray *objectsToBeSaved = [NSArray arrayWithObjects:transaction, [PFUser currentUser], nil];
        
        if ([self checkConnectivity]) {
            // there is connection, save
            [PFObject saveAllInBackground:objectsToBeSaved block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [GameUtils refreshCurrentUser];
                } else {
                    // TODO: handle error somehow
                }
            }];
        } else {
            [transaction saveEventually];
            [[PFUser currentUser] saveEventually];
        }

        NSString *message =[NSString stringWithFormat:@"You have received %@ coins, go to the Coins tab and see what you can get now!", coins];
        UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Congradulations"
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Go Now", nil] autorelease];
        alertView.tag = kAlertViewBonusCoins;
        [alertView show];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // 3 day notification
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
        message = @"Get free things with Coins. Check them out!";
    } else if ([deviceUUID isEqualToString:user.username]) {
        message = @"Signup and get free things immediately.";
    } else {
        message = @"We've added more discounts and free stuff. Check them out!";
    }

    notif.alertBody = message;
    notif.alertAction = @"Get Rewards";
    notif.soundName = UILocalNotificationDefaultSoundName;
    notif.applicationIconBadgeNumber = 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    [notif release];
    
    // 5 day notification
    UILocalNotification *notif2 = [[UILocalNotification alloc] init];

    // add 5 days
    NSDateComponents *dateComponents2 = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit )
                                                   fromDate:[[NSDate date] dateByAddingTimeInterval:60*60*120]];
    // 11:30 every morning
    [dateComponents2 setHour:11];
    [dateComponents2 setMinute:30];
    [dateComponents2 setSecond:0];
    
    notif2.fireDate = [calendar dateFromComponents:dateComponents2];
    notif2.timeZone = [NSTimeZone defaultTimeZone];

    message = @"Be in the loop! We've added more discounts and free stuff.";    
    
    notif2.alertBody = message;
    notif2.alertAction = @"Get Rewards";
    notif2.soundName = UILocalNotificationDefaultSoundName;
    notif2.applicationIconBadgeNumber = 2;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notif2];
    [notif2 release];
    
    // 7 day notification
    UILocalNotification *notif3 = [[UILocalNotification alloc] init];

    // add 7 days
    NSDateComponents *dateComponents3 = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit )
                                                   fromDate:[[NSDate date] dateByAddingTimeInterval:60*60*168]];
    // 11:30 every morning
    [dateComponents3 setHour:11];
    [dateComponents3 setMinute:30];
    [dateComponents3 setSecond:0];
    
    notif3.fireDate = [calendar dateFromComponents:dateComponents3];
    notif3.timeZone = [NSTimeZone defaultTimeZone];

    message = @"Checkout RewardCat and receive 2 free Coins now!";

    notif3.alertBody = message;
    notif3.alertAction = @"Get Rewards";
    notif3.soundName = UILocalNotificationDefaultSoundName;
    notif3.applicationIconBadgeNumber = 3;

    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"coinReward"];
    notif3.userInfo = infoDict;

    [[UIApplication sharedApplication] scheduleLocalNotification:notif3];
    [notif3 release];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    if (!self.noNetworkAlertView) {
        self.noNetworkAlertView = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                                             message:@"RewardCat requires a working Internet connection in order to work. Please ensure that you have a valid Internet connection."
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
    }

    // check to see if location service is available
    // start updating current location
    if ([LocationManager allowLocationService]) {
        [[LocationManager sharedSingleton] startUpdatingLocation];
    }

    // check connectivity
    if ([self checkConnectivity]) {
        // check to see if user needs to be logged in
        [self login];
        
        // get all vendor objects and store in cache
        [self refreshVendorCacheInBackground];
        
        // get all ads
        [AdsUtils.instance refreshAdsList];

        // setup all tab views
        [self setupAllViews];
        
        // check to see if new update is available
        [GameUtils checkIfNewVersionAvailable];
    } else {
        [self.noNetworkAlertView show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disableCamera" object:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissTutorialView" object:nil];
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)showFacebookPrompt {
    // TODO: to be developed
//    UIAlertView *facebookLoginAlertView = [[UIAlertView alloc] initWithTitle:@"Facebook"
//                                                                     message:@"Looks like your Facebook login has changed, please login with Facebook again."
//                                                                    delegate:self
//                                                           cancelButtonTitle:@"OK"
//                                                           otherButtonTitles:nil];
//    facebookLoginAlertView = kAlertViewOne;
//    [facebookLoginAlertView show];
//    [facebookLoginAlertView release];
}

- (void)refreshVendorCacheInBackground {
    // get active Vendors
    PFQuery *queryVendor = [PFQuery queryWithClassName:@"Vendor"];
    [queryVendor whereKey:@"activeFlag" equalTo:[NSNumber numberWithBool:true]];
    
    // get last vendor list refresh time
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastRefreshTime = [defaults objectForKey:@"vendorCacheLastRefreshedDate"];
    
    if (lastRefreshTime != nil && [GameUtils instance].vendorDictionary.count > 0) {
        // if it is not first time refreshing the vendor list
        // and vendor dictionary are loaded in memory
        // only query what has changed since last time it refreshed
        [queryVendor whereKey:@"updatedAt" greaterThan:lastRefreshTime];
    } else {
        // refresh the whole vendor list
        // set updated date to be prior to project launch
        NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
        [comps setYear:2012];
        [comps setMonth:12];
        [comps setDay:1];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSCalendar *cal = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        lastRefreshTime = [cal dateFromComponents:comps];
    }

    // find objects in background
    __block NSDate *lastRefreshTime_ = lastRefreshTime;
    [queryVendor findObjectsInBackgroundWithBlock:^(NSArray *allVendors, NSError *error) {
        // take each object and store it in vendor lookup dictionary
        [allVendors enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
            // objectID is the key
            PFObject *vendor = object;
            [[GameUtils instance].vendorDictionary setObject:vendor forKey:vendor.objectId];

            NSDate *updatedAt = vendor.updatedAt;
            if ([updatedAt compare:lastRefreshTime] == NSOrderedDescending) {
                // find the latest refresh time
                lastRefreshTime_ = updatedAt;
            }
        }];
        
        // set the latest refresh time in NSUserDefault
        [defaults setObject:lastRefreshTime_ forKey:@"vendorCacheLastRefreshedDate"];
        [defaults synchronize];
    }];
}

- (BOOL)checkConnectivity {
    if (!self.connected) {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [reachability currentReachabilityStatus];
        self.connected = !(networkStatus == NotReachable);
    }
    return self.connected;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertViewOne) {
        [PFFacebookUtils linkUser:[PFUser currentUser]
                      permissions:[GameUtils instance].facebookPermissions];
    } else if (alertView.tag == kAlertViewBonusCoins) {
        if (buttonIndex == 1) {
            [self.tabBarController setSelectedIndex:2];
        }
    } else {
        if ([self checkConnectivity]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"enableCamera" object:nil];
        } else {
            [self.noNetworkAlertView show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"disableCamera" object:nil];
        }
    }
}

- (void)setupAllViews {

    if (self.window == nil) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
        
        // Override point for customization after application launch.
        ScanViewController *viewController1 = [[[ScanViewController alloc] initWithNibName:@"ScanViewController" bundle:nil] autorelease];
        RewardsViewController *viewController2 = [[[RewardsViewController alloc] initWithNibName:@"RewardsViewController" bundle:nil] autorelease];
        PointRewardsViewController *viewController3 = [[[PointRewardsViewController alloc] initWithNibName:@"PointRewardsViewController" bundle:nil] autorelease];
        DiscountsViewController *viewController4 = [[[DiscountsViewController alloc] initWithNibName:@"DiscountsViewController" bundle:nil] autorelease];
        AccountViewController *viewController5 = [[[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil] autorelease];
        
        self.tabBarController = [[[RewardCatTabBarController alloc] init] autorelease];
        [GameUtils instance].tabBarController = self.tabBarController;
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

        [self.window makeKeyAndVisible];
        
        if ([GameUtils instance].firstTimeUser) {
            [GameUtils instance].firstTimeUser = NO;
            [GameUtils showTutorial];
        }
    }
}

- (void)signup {
    
    // first time user, track installation
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation saveInBackground];
    
    // sign up this user with default password and uuid
    PFUser *user = [PFUser user];
    user.username = [GameUtils uuid];
    user.password = @"password";
    [user setObject:[GameUtils uuid] forKey:@"uuid"];
    [user setObject:[NSMutableDictionary dictionary] forKey:@"progressMap"];
    if (![user signUp]) {
        // TODO: Handle and distinguish error better
        // In case of error, most likely due to network related
        // or Parse being unavailable, show no Internet error for now and retry
        [self.noNetworkAlertView show];
        [self signup];
    } else {
        // user sign up successfully, enable camera for users
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enableCamera" object:nil];
        
        // if user needs to sign up, that means they are first time user, show nux
        [GameUtils instance].firstTimeUser = YES;
    }
}

- (void)login {
    // check to see if user is already logged in and exists
    if ([self userLoggedIn]) {
        // DEV ONLY
        // user exists, refresh current user object from server
        // idealy the user shouldn't need to refresh from server
        // but in case of error data correction that we make in the back end
        // users would be able to see the changes right away with this refresh
        //[GameUtils refreshCurrentUser];
    } else {
        // to make sure user account is created and no bad data would get generated
        // disable camera until user's account is created properly
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disableCamera" object:nil];

        // no user is logged in yet, try logging with default account with uuid as username to see
        // if user used this device before
        PFUser *user = [PFUser logInWithUsername:[GameUtils uuid] password:@"password"];
        if (!user) {
            // user does not exist, first time user, sign them up as default account using uuid
            [self signup];
        } else {
            // user exists, enable camera and refresh current user object from server
            [[NSNotificationCenter defaultCenter] postNotificationName:@"enableCamera" object:nil];
            [GameUtils refreshCurrentUser];
        }
    }
}

- (BOOL)userLoggedIn {
    PFUser *currentUser = [PFUser currentUser];
    // check if user is cached
    if (currentUser) {
        if ([PFFacebookUtils isLinkedWithUser:currentUser]) {
            // associated with facebook account
            // check valid session or not
            NSString *requestPath = @"me/?fields=id,name,location,gender,birthday,email";
            FBRequest *request = [FBRequest requestForGraphPath:requestPath];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                // handle response
                if (!error) {
                    // check to see if facebook data has been saved successfully yet
                    if (![currentUser objectForKey:@"name"]) {

                        // save Facebook user data
                        // Parse the data received from facebook
                        NSDictionary *userData = (NSDictionary *)result;
                        NSString *facebookId = userData[@"id"];
                        NSString *name = userData[@"name"];
                        NSString *location = userData[@"location"][@"name"];
                        NSString *gender = userData[@"gender"];
                        NSString *email = userData[@"email"];
                        NSString *birthday = userData[@"birthday"];
                        
                        if (email) [currentUser setEmail:email];
                        if (name) [currentUser setObject:name forKey:@"name"];
                        if (location) [currentUser setObject:location forKey:@"location"];
                        if (gender) [currentUser setObject:gender forKey:@"gender"];
                        if (birthday) {
                            NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
                            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                            NSDate *birthdayDT = [dateFormatter dateFromString:birthday];
                            [currentUser setObject:birthdayDT forKey:@"birthday"];
                        }
                        if (facebookId) [currentUser setObject:facebookId forKey:@"facebookId"];
                        [currentUser saveInBackground];
                    }
                } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                            isEqualToString: @"OAuthException"]) {
                    // Invalid session, prompt them to go through Facebook flow again to revalidate their session
                    NSLog(@"The facebook session was invalidated");
                } else {
                    // TODO: See if we can handle this error
                    NSLog(@"Some other error: %@", error);
                }
            }];
            // return true right away if session is invalid, we will pop up to prompt sign in again
            return true;
        } else {
            // not a facebook user, go ahead and return
            return true;
        }
    } else {
        // not cached
        return false;
    }
}

@end
