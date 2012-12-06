//
//  HelpViewController.h
//  Rewards
//
//  Created by Chang Liu on 2012-11-10.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RewardCatViewController.h"

@interface HelpViewController : RewardCatViewController

@property (nonatomic, assign) UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;

@end
