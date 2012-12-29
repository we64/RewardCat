//
//  GameUtils.m
//  RewardCat
//
//  Created by Chang Liu on 2012-12-03.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "GameUtils.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

static GameUtils *gameUtilsInstance;

@interface GameUtils ()

@property (nonatomic) BOOL showingRedeemConfirmation;
@property (nonatomic, assign) id<UIAlertViewDelegate> redeemConfirmationDelegate;

@end

@implementation GameUtils

@synthesize showingRedeemConfirmation;
@synthesize redeemConfirmationDelegate;

+ (GameUtils *)instance {
    if (!gameUtilsInstance) {
        gameUtilsInstance = [[GameUtils alloc] init];
        gameUtilsInstance.showingRedeemConfirmation = NO;
    }
    return gameUtilsInstance;
}

+ (void)showRedeemConfirmationWithTime:(NSTimeInterval) time delegate:(id<UIAlertViewDelegate>)delegate {
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentUserRefreshed" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdateRewardList" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdatePointsRewardList" object:nil];
        } else {
            NSLog(@"Current user refresh with error %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [GameUtils instance].showingRedeemConfirmation = NO;
    [self.redeemConfirmationDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).tabBarController.view.userInteractionEnabled = YES;
}

@end
