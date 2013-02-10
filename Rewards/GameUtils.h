//
//  GameUtils.h
//  RewardCat
//
//  Created by Chang Liu on 2012-12-03.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface GameUtils : NSObject <UIAlertViewDelegate>

@property (nonatomic, retain) NSMutableDictionary *rewardRedeemStartTime;
@property (nonatomic, retain) NSMutableDictionary *pointRewardRedeemStartTime;
@property (nonatomic, retain) NSMutableDictionary *vendorDictionary;
@property (nonatomic, retain) NSNumberFormatter *distanceFormatter;
@property (nonatomic, retain) NSDateFormatter *expireDateFormatter;
@property (nonatomic) BOOL hasUserUpdatedForReward;
@property (nonatomic) BOOL hasUserUpdatedForCoin;
@property (nonatomic) BOOL hasUserUpdatedForTransaction;

+ (void)showRedeemConfirmationWithTime:(NSTimeInterval)time delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)refreshCurrentUser;
+ (GameUtils *)instance;
+ (NSDate *)getToday;
- (PFObject *)getVendor:(NSString *)vendorObjectId;
+ (void)showProcessing;
+ (void)hideProgressing;
+ (void)showDoobersWithStamp:(int)stamp coin:(int)coin vendorName:(NSString *)vendorName;
+ (NSString *)timeStringWithGmtTimeInt:(NSTimeInterval)time;
+ (NSString *)uuid;

@end
