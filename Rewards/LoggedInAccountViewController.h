//
//  LoggedInAccountViewController.h
//  RewardCat
//
//  Created by Chang Liu on 2012-11-24.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "HistoryTableViewController.h"

@interface LoggedInAccountViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIView *tableViewContainer;

- (IBAction)supportButtonClicked:(id)sender;
- (IBAction)rateButtonClicked:(id)sender;
- (IBAction)likeButtonClicked:(id)sender;

@end
