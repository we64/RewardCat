//
//  ScanViewController.h
//  Rewards
//
//  Created by Chang Liu on 2012-09-29.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarReaderViewController.h"
#import "RewardCatViewController.h"

@interface ScanViewController : RewardCatViewController <ZBarReaderDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *scanBox;
@property (nonatomic, retain) UITabBarController *tabBarController;

- (BOOL)connected;

@end
