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

+ (GameUtils *)instance {
    if (!gameUtilsInstance) {
        gameUtilsInstance = [[GameUtils alloc] init];

        gameUtilsInstance.rewardRedeemStartTime = [[NSMutableDictionary alloc] init];
        gameUtilsInstance.pointRewardRedeemStartTime = [[NSMutableDictionary alloc] init];
        gameUtilsInstance.vendorDictionary = [[NSMutableDictionary alloc] init];
        gameUtilsInstance.showingRedeemConfirmation = NO;
        gameUtilsInstance.distanceFormatter = [[NSNumberFormatter alloc] init];
        [gameUtilsInstance.distanceFormatter setPositiveFormat:@"0.#"];
        gameUtilsInstance.expireDateFormatter = [[NSDateFormatter alloc] init];
        [gameUtilsInstance.expireDateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
    }
    return gameUtilsInstance;
}

+ (void)showRedeemConfirmationWithTime:(NSTimeInterval)time delegate:(id<UIAlertViewDelegate>)delegate {
    if ([GameUtils instance].showingRedeemConfirmation) {
        return;
    }
    [GameUtils instance].redeemConfirmationDelegate = delegate;
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController.view.userInteractionEnabled = NO;
    NSTimeInterval redeemTimeLength = time;
    int seconds = (int)floor(redeemTimeLength) % 60;
    int minutes = (int)floor(redeemTimeLength / 60) % 60;
    int hours = (int)floor(redeemTimeLength / 3600);
    NSString *redeemTimeLengthText = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Are you sure you want to redeem this reward?"
                                                     message:[NSString stringWithFormat:@"You will have %@ to redeem this reward", redeemTimeLengthText]
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [GameUtils instance].showingRedeemConfirmation = NO;
    [self.redeemConfirmationDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController.view.userInteractionEnabled = YES;
}

- (void)dealloc {
    [expireDateFormatter release], expireDateFormatter = nil;
    [distanceFormatter release], distanceFormatter = nil;
    [rewardRedeemStartTime release], rewardRedeemStartTime = nil;
    [pointRewardRedeemStartTime release], pointRewardRedeemStartTime = nil;
    [vendorDictionary release], vendorDictionary = nil;
    [processingView release], processingView = nil;
    [dooberView release], dooberView = nil;
    [super dealloc];
}

+ (void)showProcessing {
    if (![GameUtils instance].processing) {
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
        window.userInteractionEnabled = NO;
        [window bringSubviewToFront:[GameUtils instance].processingView];
        [window bringSubviewToFront:[GameUtils instance].dooberView];
        [GameUtils instance].processingView.hidden = NO;
        [GameUtils instance].processing = YES;
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
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"MMM dd, yyyy\nHH:mm:ss"];
    return [formatter stringFromDate:date];
}

+ (NSString *)uuid {
    return [[UIDevice currentDevice] uniqueDeviceIdentifier];
}

@end
