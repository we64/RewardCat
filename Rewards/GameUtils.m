//
//  GameUtils.m
//  RewardCat
//
//  Created by Chang Liu on 2012-12-03.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "GameUtils.h"
#import "AppDelegate.h"
#import "ProcessingView.h"
#import "DooberView.h"
#import "TutorialView.h"
#import <Parse/Parse.h>
#import "UIDevice+IdentifierAddition.h"

static GameUtils *gameUtilsInstance;

@interface GameUtils ()

@property (nonatomic) BOOL showingRedeemConfirmation;
@property (nonatomic, assign) id<UIAlertViewDelegate> redeemConfirmationDelegate;
@property (nonatomic, retain) ProcessingView *processingView;
@property (nonatomic, retain) DooberView *dooberView;
@property (nonatomic) BOOL processing;

@end

@implementation GameUtils

@synthesize showingRedeemConfirmation;
@synthesize redeemConfirmationDelegate;
@synthesize rewardRedeemStartTime;
@synthesize pointRewardRedeemStartTime;
@synthesize vendorDictionary;
@synthesize distanceFormatter;
@synthesize expireDateFormatter;
@synthesize processingView;
@synthesize processing;
@synthesize dooberView;
@synthesize hasUserUpdatedForReward;
@synthesize hasUserUpdatedForCoin;
@synthesize hasUserUpdatedForTransaction;
@synthesize tabBarController;
@synthesize facebookPermissions;
@synthesize firstTimeUser;

+ (GameUtils *)instance {
    if (!gameUtilsInstance) {
        gameUtilsInstance = [[GameUtils alloc] init];

        gameUtilsInstance.rewardRedeemStartTime = [[[NSMutableDictionary alloc] init] autorelease];
        gameUtilsInstance.pointRewardRedeemStartTime = [[[NSMutableDictionary alloc] init] autorelease];
        gameUtilsInstance.vendorDictionary = [[[NSMutableDictionary alloc] init] autorelease];
        gameUtilsInstance.showingRedeemConfirmation = NO;
        gameUtilsInstance.distanceFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        gameUtilsInstance.distanceFormatter.positiveFormat = @"0.#";
        gameUtilsInstance.expireDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        gameUtilsInstance.expireDateFormatter.dateFormat = @"EEE, MMM dd, yyyy";
        gameUtilsInstance.facebookPermissions = [NSArray arrayWithObjects:@"user_birthday", @"publish_stream", @"email", @"user_location", nil];
        gameUtilsInstance.firstTimeUser = NO;
    }
    return gameUtilsInstance;
}

- (void)dealloc {
    [expireDateFormatter release], expireDateFormatter = nil;
    [distanceFormatter release], distanceFormatter = nil;
    [rewardRedeemStartTime release], rewardRedeemStartTime = nil;
    [pointRewardRedeemStartTime release], pointRewardRedeemStartTime = nil;
    [vendorDictionary release], vendorDictionary = nil;
    [processingView release], processingView = nil;
    [dooberView release], dooberView = nil;
    [facebookPermissions release], facebookPermissions = nil;
    [super dealloc];
}

- (PFObject *)getVendor:(NSString *)vendorObjectId {
    
    // check vendor cache
    PFObject *vendor = [self.vendorDictionary objectForKey:vendorObjectId];
    if (!vendor && vendorObjectId) {
        // cache miss, retrieve
        PFQuery *query = [PFQuery queryWithClassName:@"Vendor"];
        vendor = [query getObjectWithId:vendorObjectId];
        [self.vendorDictionary setObject:vendor forKey:vendorObjectId];
    }
    return vendor;
}

- (void)mergeDefaultAccountWithFacebookOrSignedUp:(PFUser *)user actionType:(NSString *)type previousUser:(PFUser *)previousUser {
    
    // merge progress
    NSDictionary *mergedProgress = [self mergeProgress:[user objectForKey:@"progressMap"] with:[previousUser objectForKey:@"progressMap"]];
    
    // merge points
    int totalPoints = [[previousUser objectForKey:@"rewardcatPoints"] intValue] + [[user objectForKey:@"rewardcatPoints"] intValue];
    
    // Need to delete device user after logging in and need to correct transaction userObjectId to the new logged in user
    NSArray *keys = [NSArray arrayWithObjects:@"userObjectId", @"username", @"progressMap", @"rewardcatPoints", @"uuid", @"type", nil];
    NSArray *objects = [NSArray arrayWithObjects:
                        previousUser.objectId,
                        previousUser.username,
                        mergedProgress,
                        [NSNumber numberWithInt:totalPoints],
                        [previousUser objectForKey:@"uuid"],
                        type,
                        nil];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects
                                                           forKeys:keys];
    [PFCloud callFunctionInBackground:@"MergeDeleteUserAndUpdateTransaction" withParameters:dictionary block:^(id result, NSError *error) {
        if (error) {
            NSLog(@"Device user deletion failed");
            [[[[UIAlertView alloc] initWithTitle:@"Log In Failed"
                                         message:@"Sorry, seems like we have a problem with login, please try again later."
                                        delegate:nil
                               cancelButtonTitle:@"Ok"
                               otherButtonTitles:nil] autorelease] show];
        } else {
            [GameUtils refreshCurrentUser];
            NSLog(@"Device user deletion successful");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showSignedInAccountPage" object:nil];
        }
    }];
}

- (NSDictionary *)mergeProgress:(NSDictionary *)account with:(NSDictionary *)onDevice {
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:account];
    
    [onDevice enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if ([account objectForKey:key] != nil) {
            // account has this key, merge
            NSMutableDictionary *newVal = [NSMutableDictionary dictionaryWithDictionary:[account objectForKey:key]];
            
            int newCount = [[newVal objectForKey:@"Count"] intValue] + [[obj objectForKey:@"Count"] intValue];
            [newVal setObject:[NSNumber numberWithInt:newCount] forKey:@"Count"];
            
            int newLastScan = MAX([[obj objectForKey:@"LastScanTimeStamp"] intValue], [[newVal objectForKey:@"LastScanTimeStamp"] intValue]);
            [newVal setObject:[NSNumber numberWithInt:newLastScan] forKey:@"LastScanTimeStamp"];
            
            [result setObject:newVal forKey:key];
        } else {
            // account does not have this key, simply add
            [result setObject:obj forKey:key];
        }
    }];
    
    return (NSDictionary *) [[result mutableCopy] autorelease];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [GameUtils instance].showingRedeemConfirmation = NO;
    [self.redeemConfirmationDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController.view.userInteractionEnabled = YES;
}

+ (void)showFacebookDialog {
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [PFFacebookUtils linkUser:[PFUser currentUser]
                      permissions:[GameUtils instance].facebookPermissions target:self
                         selector:@selector(showFacebookDialogHelper)];
    } else {
        [GameUtils showFacebookDialogHelper];
    }
}

+ (void)showFacebookDialogHelper {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Stay in the loop. Get rewards and discounts with RewardCat!", @"message", nil];
    PFFacebookUtils.facebook.accessToken = [PFFacebookUtils session].accessToken;
    PFFacebookUtils.facebook.expirationDate = [PFFacebookUtils session].expirationDate;
    [PFFacebookUtils.facebook dialog:@"apprequests" andParams:params andDelegate:[GameUtils instance]];
}

- (void)dialogCompleteWithUrl:(NSURL *)url {
    // Call back after invites are sent
    // try to get the number of valid invites
    // a friend can only be invited once

    NSDictionary *params = [self parseURLParams:[url query]];
    if ([params objectForKey:@"request"]) {
        int requestCount = 0;
        NSMutableDictionary *invitedFBFriends = [[PFUser currentUser] objectForKey:@"invitedFBFriends"];
        if (!invitedFBFriends) {
            invitedFBFriends = [NSMutableDictionary dictionary];
        }
        
        // count the number of valid requests
        for (NSString *key in params.allKeys) {
            if ([[key substringToIndex:2] isEqualToString:@"to"]) {
                NSString *fbuid = [params objectForKey:key];
                if (![invitedFBFriends objectForKey:fbuid]) {
                    requestCount++;
                    [invitedFBFriends setObject:[NSNumber numberWithBool:YES] forKey:fbuid];
                }
            }
        }
        if (requestCount > 0) {
            // valid request count is greater than 1
            // save to user
            [[PFUser currentUser] setObject:invitedFBFriends forKey:@"invitedFBFriends"];
            [[PFUser currentUser] incrementKey:@"rewardcatPoints" byAmount:[NSNumber numberWithInt:requestCount]];
            PFObject *transaction = [PFObject objectWithClassName:@"Transaction"];
            [transaction setObject:@"Facebook Invite Friends" forKey:@"activityType"];
            [transaction setObject:[NSNumber numberWithInt:requestCount] forKey:@"rewardcatPointsDelta"];
            [transaction setObject:[PFUser currentUser] forKey:@"user"];
            NSArray *objectsToBeSaved = [NSArray arrayWithObjects:transaction, [PFUser currentUser], nil];
            [PFObject saveAllInBackground:objectsToBeSaved block:^(BOOL succeeded, NSError *error) {
                // TODO: Write better pop up messages
                if (succeeded) {
                    [GameUtils refreshCurrentUser];
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Congradulations"
                                                                     message:[NSString stringWithFormat:@"You have earned %d coin!", requestCount]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Awesome"
                                                           otherButtonTitles:nil] autorelease];
                    [alert show];
                } else {
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Sorry"
                                                                     message:[NSString stringWithFormat:@"You have earned %d coin!", requestCount]
                                                                    delegate:[GameUtils instance]
                                                           cancelButtonTitle:@"Bad"
                                                           otherButtonTitles:nil] autorelease];
                    [alert show];
                }
            }];
        }
    }
}

- (NSDictionary*)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
    return params;
}

+ (void)showRedeemConfirmationWithTime:(NSTimeInterval)time delegate:(id<UIAlertViewDelegate>)delegate {
    if ([GameUtils instance].showingRedeemConfirmation) {
        return;
    }
    [GameUtils instance].redeemConfirmationDelegate = delegate;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController.view.userInteractionEnabled = NO;
    NSTimeInterval redeemTimeLength = time;
    int minutes = (int)floor(redeemTimeLength / 60) % 60;
    NSString *redeemTimeLengthText = [NSString stringWithFormat:@"%d", minutes];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Are you sure you want to get this reward now?"
                                                     message:[NSString stringWithFormat:@"You will have %@ minutes to show the cashier this page.", redeemTimeLengthText]
                                                    delegate:[GameUtils instance]
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK", nil] autorelease];
    [alert show];
    [GameUtils instance].showingRedeemConfirmation = YES;
}

+ (void)refreshCurrentUser {
    [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (!error) {
            NSLog(@"Current user refresh successful");
            [GameUtils instance].hasUserUpdatedForReward = YES;
            [GameUtils instance].hasUserUpdatedForCoin = YES;
            [GameUtils instance].hasUserUpdatedForTransaction = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentUserRefreshed" object:nil];
        } else {
            NSLog(@"Current user refresh with error %@ %@", error, [error userInfo]);
        }
    }];
}

+ (NSDate *)getToday {
    NSDate *today = nil;
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&today interval:NULL forDate:[NSDate date]];
    return today;
}

+ (void)showTutorialWithFacebook:(BOOL)showFacebookPage {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"TutorialView"
                                                      owner:self
                                                    options:nil];
    TutorialView *tutorialView = [nibViews objectAtIndex:0];
    tutorialView.showFacebookPage = showFacebookPage;
    tutorialView.page = 0;
    tutorialView.frame = window.frame;
    [window addSubview:tutorialView];
}

+ (void)showTutorial {
    [GameUtils showTutorialWithFacebook:YES];
}

+ (void)showProcessingDisplay {
    if ([GameUtils instance].processing) {
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        if (!window) {
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        }
        if (![GameUtils instance].processingView) {
            NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"ProcessingView"
                                                              owner:self
                                                            options:nil];
            [GameUtils instance].processingView = [nibViews objectAtIndex:0];
            [GameUtils instance].processingView.frame = window.frame;
            [window addSubview:[GameUtils instance].processingView];
        }
        [window bringSubviewToFront:[GameUtils instance].processingView];
        [window bringSubviewToFront:[GameUtils instance].dooberView];
        [GameUtils instance].processingView.hidden = NO;
    }
}

+ (void)showProcessing {
    if (![GameUtils instance].processing) {
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        if (!window) {
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        }
        window.userInteractionEnabled = NO;
        [GameUtils instance].processing = YES;
        [[GameUtils class] performSelector:@selector(showProcessingDisplay) withObject:nil afterDelay:2];
    }
}

+ (void)hideProgressing {
    if ([GameUtils instance].processing) {
        [GameUtils instance].processing = NO;
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        if (!window) {
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        }
        window.userInteractionEnabled = YES;
        [GameUtils instance].processingView.hidden = YES;
    }
}

+ (void)showDoobersWithStamp:(int)stamp coin:(int)coin vendorName:(NSString *)vendorName {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    if (![GameUtils instance].dooberView) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"DooberView"
                                                          owner:self
                                                        options:nil];
        [GameUtils instance].dooberView = [nibViews objectAtIndex:0];
        [window addSubview:[GameUtils instance].dooberView];
    }
    [window bringSubviewToFront:[GameUtils instance].dooberView];
    [[GameUtils instance].dooberView showWithStamp:stamp coin:coin vendorName:vendorName];
}

+ (NSString *)timeStringWithGmtTimeInt:(NSTimeInterval)time {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter=[[[NSDateFormatter alloc] init] autorelease];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"MMM dd, yyyy\nHH:mm"];
    return [formatter stringFromDate:date];
}

+ (NSString *)uuid {
    return [[UIDevice currentDevice] uniqueDeviceIdentifier];
}

@end
