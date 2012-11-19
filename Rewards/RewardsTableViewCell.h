//
//  RewardsTableViewCell.h
//  Rewards
//
//  Created by Chang Liu on 2012-10-07.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "RewardsTableViewController.h"

@interface RewardsTableViewCell : UITableViewCell <UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UILabel *detailTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIView *imageContainerView;
@property (nonatomic, retain) IBOutlet UIButton *redeemButton;
@property (nonatomic, retain) IBOutlet UIButton *detailsButton;
@property (nonatomic, retain) IBOutlet UIView *progressParentView;
@property (nonatomic, retain) IBOutlet UIView *progressView;

@property (nonatomic, retain) PFObject *item;
@property (nonatomic, retain) RewardsTableViewController *rewardsTableViewController;
@property (nonatomic, retain) PFFile *imageFile;

@property (nonatomic) int indexInTable;

- (void)setUpWithItem:(PFObject *)item;
- (IBAction)detailsButtonClicked:(id)sender;
- (IBAction)redeemButtonClicked:(id)sender;

@end
