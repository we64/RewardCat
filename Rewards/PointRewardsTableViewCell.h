//
//  PointRewardsTableViewCell.h
//  Rewards
//
//  Created by Chang Liu on 2012-11-11.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PointRewardsTableViewController.h"

@interface PointRewardsTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *detailTextLabels;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *textLabels;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *pointsLabels;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *distanceLabels;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *imageContainerViews;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *starViews;
@property (nonatomic, retain) IBOutletCollection(UIButton) NSArray *detailsButtons;

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) PointRewardsTableViewController *pointRewardsTableViewController;
@property (nonatomic, retain) NSArray *imageFiles;

@property (nonatomic, retain) NSArray *indicesInTable;

- (void)setUpWithItems:(NSArray *)items_;
- (IBAction)detailsButtonClicked:(id)sender;

@end
