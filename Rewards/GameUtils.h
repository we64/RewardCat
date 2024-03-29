//
//  GameUtils.h
//  RewardCat
//
//  Created by Chang Liu on 2012-12-03.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardCatTabBarController.h"
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface GameUtils : NSObject <UIAlertViewDelegate>

@property (nonatomic, retain) NSMutableDictionary *rewardRedeemStartTime;
@property (nonatomic, retain) NSMutableDictionary *pointRewardRedeemStartTime;
@property (nonatomic, retain) NSMutableDictionary *vendorDictionary;
@property (nonatomic, retain) NSNumberFormatter *distanceFormatter;
@property (nonatomic, retain) NSDateFormatter *expireDateFormatter;
@property (nonatomic, retain) NSArray *facebookPermissions;
@property (nonatomic, retain) PFObject *currentCategory;
@property (nonatomic) BOOL hasUserUpdatedForTransaction;
@property (nonatomic, assign) RewardCatTabBarController *tabBarController;
@property (nonatomic) BOOL firstTimeUser;
@property (nonatomic, retain) NSString *nextGoToPointsRewardId;

- (PFObject *)getVendor:(NSString *)vendorObjectId;
- (void)mergeDefaultAccountWithFacebookOrSignedUp:(PFUser *)user actionType:(NSString *)type previousUser:(PFUser *)previousUser showDialog:(BOOL)showDialog;

+ (NSDictionary*)parseURLParams:(NSString *)query;
+ (GameUtils *)instance;
+ (void)showRedeemConfirmationWithTime:(NSTimeInterval)time delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)refreshCurrentUser;
+ (NSDate *)getToday;
+ (NSString *)timeStringWithGmtTimeInt:(NSTimeInterval)time;
+ (NSString *)uuid;
+ (void)showProcessing;
+ (void)hideProgressing;
+ (void)showDoobersWithStamp:(int)stamp coin:(int)coin vendorName:(NSString *)vendorName inviteMessage:(NSString *)inviteMessage pointReward:(PFObject *)pointReward instructionMessage:(NSString *)instructionMessage;
+ (void)showTutorial;
+ (void)showFacebookDialog;
+ (void)showTutorialWithFacebook:(BOOL)showFacebookPage;
+ (UIWindow *)topLevelView;
+ (void)explodeCoins;
+ (void)checkIfNewVersionAvailable;
+ (void)goToAppStore;
+ (void)hideDooberView;

@end
