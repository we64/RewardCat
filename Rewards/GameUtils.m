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
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
#import "Logger.h"

#define kAlertViewRedeem 1
#define kAlertViewNewUpdate 2

static GameUtils *gameUtilsInstance;

@interface GameUtils ()

@property (nonatomic) BOOL showingRedeemConfirmation;
@property (nonatomic, assign) id<UIAlertViewDelegate> redeemConfirmationDelegate;
@property (nonatomic, retain) ProcessingView *processingView;
@property (nonatomic, retain) DooberView *dooberView;
@property (nonatomic) BOOL processing;
@property (nonatomic, retain) CAEmitterLayer *coinExplosionParticleEmitter;

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
@synthesize hasUserUpdatedForTransaction;
@synthesize tabBarController;
@synthesize facebookPermissions;
@synthesize firstTimeUser;
@synthesize currentCategory;
@synthesize coinExplosionParticleEmitter;
@synthesize nextGoToPointsRewardId;

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
        PFQuery *query = [PFQuery queryWithClassName:@"Category"];
        [query whereKey:@"showAll" equalTo:[NSNumber numberWithBool:YES]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            gameUtilsInstance.currentCategory = object;
        }];
    }
    return gameUtilsInstance;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [expireDateFormatter release], expireDateFormatter = nil;
    [distanceFormatter release], distanceFormatter = nil;
    [rewardRedeemStartTime release], rewardRedeemStartTime = nil;
    [pointRewardRedeemStartTime release], pointRewardRedeemStartTime = nil;
    [vendorDictionary release], vendorDictionary = nil;
    [processingView release], processingView = nil;
    [dooberView release], dooberView = nil;
    [facebookPermissions release], facebookPermissions = nil;
    [currentCategory release], currentCategory = nil;
    [coinExplosionParticleEmitter release], coinExplosionParticleEmitter = nil;
    [nextGoToPointsRewardId release], nextGoToPointsRewardId = nil;
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

- (void)mergeDefaultAccountWithFacebookOrSignedUp:(PFUser *)user actionType:(NSString *)type previousUser:(PFUser *)previousUser showDialog:(BOOL)showDialog {
    
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
            if (showDialog) {
                [GameUtils showFacebookDialogHelper];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showSignedInAccountPage" object:nil];
            }
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
    if (alertView.tag == kAlertViewRedeem && buttonIndex != [alertView cancelButtonIndex]) {
        [GameUtils instance].showingRedeemConfirmation = NO;
        [self.redeemConfirmationDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController.view.userInteractionEnabled = YES;
    } else if (alertView.tag == kAlertViewNewUpdate && buttonIndex != [alertView cancelButtonIndex]) {
        [Logger.instance logButtonClick:@"Clicked upgrade to new version to App Store" pageName:nil];
        [GameUtils goToAppStore];
    }
}

+ (void)goToAppStore {
    NSString* url = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", @"584774055"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
}

+ (void)showFacebookDialog {
    PFUser *user = [PFUser currentUser];
    if (![PFFacebookUtils isLinkedWithUser:user]) {
        if ([user.username isEqualToString:[user objectForKey:@"uuid"]]) {
            // the user is using default account still, create proper facebook and merge
            [PFFacebookUtils logInWithPermissions:[GameUtils instance].facebookPermissions block:^(PFUser *newUser, NSError *error) {
                if (!newUser) {
                    // TODO: show better message
                    NSLog(@"Facebook account login/create error");
                } else {
                    [[GameUtils instance] mergeDefaultAccountWithFacebookOrSignedUp:newUser
                                                                         actionType:@"facebook"
                                                                       previousUser:user showDialog:YES];
                }
            }];
        } else {
            // user is a registered user, link the account to facebook
            [PFFacebookUtils linkUser:[PFUser currentUser]
                          permissions:[GameUtils instance].facebookPermissions target:self
                             selector:@selector(showFacebookDialogHelper)];
        }
    } else {
        [GameUtils showFacebookDialogHelper];
    }
}

+ (void)showFacebookDialogHelper {
    NSMutableDictionary *invitedFriends = [[PFUser currentUser] objectForKey:@"invitedFBFriends"];
    NSString *excluded_ids = [[invitedFriends allKeys] componentsJoinedByString:@","];
    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:excluded_ids, @"exclude_ids", nil] autorelease];

    [FBWebDialogs
     presentRequestsDialogModallyWithSession:[PFFacebookUtils session]
     message:@"Stay in the loop. Get rewards and discounts with RewardCat!"
     title:@"Get RewardCat"
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Case A: Error launching the dialog or sending request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // Case B: User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Case C: Dialog shown and the user clicks Cancel or Send
                 NSDictionary *params = [GameUtils parseURLParams:[resultURL query]];
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
                                                                                  message:[NSString stringWithFormat:@"There seem to be an error sending the requests, please try again later."]
                                                                                 delegate:[GameUtils instance]
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil] autorelease];
                                 [alert show];
                             }
                         }];
                     }
                 }
             }
         }
     }];
}

+ (void)hideDooberView {
    // hide dooberView if exists
    if ([GameUtils instance].dooberView && ![GameUtils instance].dooberView.hidden) {
        [GameUtils instance].dooberView.hidden = YES;
    }
}

+ (NSDictionary*)parseURLParams:(NSString *)query {
	NSArray *pairs = [query componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *pair in pairs) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[params setObject:val forKey:[kv objectAtIndex:0]];
	}
    return params;
}

+ (void)showRedeemConfirmationWithTime:(NSTimeInterval)redeemTimeLength delegate:(id<UIAlertViewDelegate>)delegate {
    if ([GameUtils instance].showingRedeemConfirmation) {
        return;
    }
    [GameUtils instance].redeemConfirmationDelegate = delegate;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController.view.userInteractionEnabled = NO;
    int minutes = (int)floor(redeemTimeLength / 60);
    int seconds = (int)redeemTimeLength % 60;

    NSString *redeemTimeLengthText;
    if (seconds > 0) {
        redeemTimeLengthText = [NSString stringWithFormat:@"%d minutes and %d seconds", minutes, seconds];
    } else {
        redeemTimeLengthText = [NSString stringWithFormat:@"%d minutes", minutes];
    }
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Are you sure you want to get this reward now?"
                                                     message:[NSString stringWithFormat:@"You will have %@ to show the cashier this page to complete this redemption.", redeemTimeLengthText]
                                                    delegate:[GameUtils instance]
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK", nil] autorelease];
    alert.tag = kAlertViewRedeem;
    [alert show];
    [GameUtils instance].showingRedeemConfirmation = YES;
}

+ (void)refreshCurrentUser {
    [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (!error) {
            NSLog(@"Current user refresh successful");
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
    UIWindow* window = [GameUtils topLevelView];
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
        UIWindow* window = [GameUtils topLevelView];
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
        UIWindow* window = [GameUtils topLevelView];
        window.userInteractionEnabled = NO;
        [GameUtils instance].processing = YES;
        [[GameUtils class] performSelector:@selector(showProcessingDisplay) withObject:nil afterDelay:0.5];
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

+ (UIWindow *)topLevelView {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    return window;
}

+ (void)showDoobersWithStamp:(int)stamp coin:(int)coin vendorName:(NSString *)vendorName inviteMessage:(NSString *)inviteMessage pointReward:(PFObject *)pointReward instructionMessage:(NSString *)instructionMessage {

    UIWindow* window = [GameUtils topLevelView];
    if (![GameUtils instance].dooberView) {
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"DooberView"
                                                          owner:self
                                                        options:nil];
        [GameUtils instance].dooberView = [nibViews objectAtIndex:0];
        [window addSubview:[GameUtils instance].dooberView];
    }
    [window bringSubviewToFront:[GameUtils instance].dooberView];
    [[GameUtils instance].dooberView showWithStamp:stamp coin:coin vendorName:vendorName inviteMessage:inviteMessage pointReward:pointReward instructionMessage:instructionMessage];
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [GameUtils explodeCoins];
    [GameUtils instance].dooberView.animationContainerView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.75 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [GameUtils instance].dooberView.animationContainerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
    }];
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

- (void)stopExplodeCoins {
    self.coinExplosionParticleEmitter.birthRate = 0;
}

- (void)removeExplodeCoins {
    [self.coinExplosionParticleEmitter removeFromSuperlayer];
    self.coinExplosionParticleEmitter = nil;
}

+ (void)checkIfNewVersionAvailable {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastCheckUpdateRefreshDate = [defaults objectForKey:@"lastCheckUpdateRefreshDate"];

    if (!lastCheckUpdateRefreshDate || [lastCheckUpdateRefreshDate compare:[NSDate date]] == NSOrderedAscending) {
        PFQuery *query = [PFQuery queryWithClassName:@"Version"];
        query.limit = 1;
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSNumber *currentVersion = (NSNumber *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
            NSNumber *newVersion = (NSNumber *)[object objectForKey:@"versionNumber"];
            if ([currentVersion doubleValue] < [newVersion doubleValue]) {
                NSString *message = [[object objectForKey:@"updateMessage"] objectForKey:@"message"];
                UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Update Available"
                                                                 message:message
                                                                delegate:[GameUtils instance]
                                                       cancelButtonTitle:@"Remind Me Later"
                                                       otherButtonTitles:@"Update Now", nil] autorelease];
                alert.tag = kAlertViewNewUpdate;
                [Logger.instance logEvent:@"Upgrade dialog shown"];
                [alert show];
            }

            // only check if update is available, every 2 days
            // this is for reducing unnecessary bandwidth usage
            [defaults setObject:[[NSDate date] dateByAddingTimeInterval:60*60*24*2] forKey:@"lastCheckUpdateRefreshDate"];
            [defaults synchronize];
        }];
    }
}

+ (CAEmitterCell *)standardParticleWithImage:(NSString *)imageName andScale:(CGFloat)scale {
    CAEmitterCell *particle = [CAEmitterCell emitterCell];
    
    particle.scale = scale;
    particle.scaleRange = 0.5 * scale;
    particle.velocity = 400;
    particle.birthRate = 200;
    particle.lifetime = 5;
    particle.velocityRange = 400;
    particle.emissionRange = 6.28;
    particle.yAcceleration = 400;
    particle.spinRange = 20;
    particle.contents = (id)[[UIImage imageNamed:imageName] CGImage];
    
    return particle;
}

+ (void)explodeCoins {
    if (!NSClassFromString(@"CAEmitterLayer") || !NSClassFromString(@"CAEmitterCell")) {
        return;
    }
    
    [[GameUtils instance] stopExplodeCoins];
    [[GameUtils instance] removeExplodeCoins];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:[GameUtils instance] selector:@selector(stopExplodeCoins) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:[GameUtils instance] selector:@selector(removeExplodeCoins) object:nil];
    
    [GameUtils instance].coinExplosionParticleEmitter = [CAEmitterLayer layer];
    [GameUtils instance].coinExplosionParticleEmitter.seed = [[NSDate date] timeIntervalSince1970];
    [GameUtils instance].coinExplosionParticleEmitter.backgroundColor = [[UIColor redColor] CGColor];
    [GameUtils instance].coinExplosionParticleEmitter.position = [GameUtils instance].tabBarController.view.center;
    [GameUtils instance].coinExplosionParticleEmitter.emitterShape = kCAEmitterLayerPoint;
    [GameUtils instance].coinExplosionParticleEmitter.renderMode = kCAEmitterLayerUnordered;
    
    [GameUtils instance].coinExplosionParticleEmitter.emitterCells = [NSArray arrayWithObjects:
                                                                      [GameUtils standardParticleWithImage:@"coin@2x" andScale:0.33],
                                                                      [GameUtils standardParticleWithImage:@"stamp@2x" andScale:0.33],
                                                                      [GameUtils standardParticleWithImage:@"saletagIcon@2x" andScale:0.5],
                                                                      nil];
    
    if (![[GameUtils instance].dooberView.layer.sublayers containsObject:[GameUtils instance].coinExplosionParticleEmitter]) {
        [[GameUtils instance].dooberView.layer addSublayer:[GameUtils instance].coinExplosionParticleEmitter];
    }
    
    [[GameUtils instance] performSelector:@selector(stopExplodeCoins) withObject:nil afterDelay:0.01];
    [[GameUtils instance] performSelector:@selector(removeExplodeCoins) withObject:nil afterDelay:10];
}

@end
