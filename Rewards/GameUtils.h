//
//  GameUtils.h
//  RewardCat
//
//  Created by Chang Liu on 2012-12-03.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameUtils : NSObject <UIAlertViewDelegate>

+ (void)showRedeemConfirmationWithTime:(NSTimeInterval) time delegate:(id<UIAlertViewDelegate>)delegate;

@end
