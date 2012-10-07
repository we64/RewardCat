//
//  ScanViewController.h
//  Rewards
//
//  Created by Chang Liu on 2012-09-29.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarReaderViewController.h"

@interface ScanViewController : UIViewController <ZBarReaderDelegate>

@property (nonatomic, retain) UITabBarController *tabBarController;

@end
