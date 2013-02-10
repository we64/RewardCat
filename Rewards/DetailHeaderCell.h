//
//  DetailHeaderCell.h
//  RewardCat
//
//  Created by Chang Liu on 2012-12-01.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DetailHeaderCell : UITableViewCell <UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *icon;
@property (nonatomic, retain) IBOutlet UIView *progressParentView;
@property (nonatomic, retain) IBOutlet UIButton *redeemButton;
@property (nonatomic, retain) IBOutlet UIButton *salesButton;
@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UIView *progressSubParentView;
@property (nonatomic, retain) IBOutlet UIView *countDownParentView;
@property (nonatomic, retain) IBOutlet UILabel *countDownLabel;
@property (nonatomic, retain) IBOutlet UILabel *businessNameLabel;

@property (nonatomic) BOOL redeem;

- (void)setUpWithReward:(PFObject *)reward_ redeem:(BOOL)redeem_;

@end
