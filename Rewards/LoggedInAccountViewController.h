//
//  LoggedInAccountViewController.h
//  RewardCat
//
//  Created by Chang Liu on 2012-11-24.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface LoggedInAccountViewController : UIViewController <MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *accountTableView;
@property (nonatomic, assign) UINavigationController *accountNavigationController;

- (void)supportButtonClicked;
- (void)rateButtonClicked;
- (void)likeButtonClicked;
- (void)historyButtonClicked;

@end
