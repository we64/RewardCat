//
//  DetailHeaderCell.m
//  RewardCat
//
//  Created by Chang Liu on 2012-12-01.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "DetailHeaderCell.h"
#import "GameUtils.h"

@interface DetailHeaderCell()

@property (nonatomic, retain) PFObject *reward;

@end

@implementation DetailHeaderCell

@synthesize reward;
@synthesize icon;
@synthesize progressParentView;
@synthesize progressView;
@synthesize redeemButton;
@synthesize countDownParentView;
@synthesize countDownLabel;
@synthesize businessNameLabel;
@synthesize redeem;

- (void)refreshIfNotRedeeming {
    if (!self.redeem) {
        [self setUpWithReward:self.reward redeem:NO];
    }
}

- (void)updateCountDownLabel:(NSNotification *)notification {
    NSString *rewardId = [notification.userInfo objectForKey:@"rewardID"];
    if (![self.reward.objectId isEqualToString:rewardId]) {
        return;
    }
    NSString *text = [notification.userInfo objectForKey:@"text"];
    self.countDownLabel.text = text;
}

- (void)redeemTimerExpired:(NSNotification *)notification {
    NSString *rewardId = [notification.userInfo objectForKey:@"rewardID"];
    if (![self.reward.objectId isEqualToString:rewardId]) {
        return;
    }
    [self setUpWithReward:self.reward redeem:NO];
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshIfNotRedeeming) name:@"currentUserRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCountDownLabel:) name:@"updateCountDownLabel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redeemTimerExpired:) name:@"redeemTimerExpired" object:nil];
}

- (void)setUpWithReward:(PFObject *)reward_ redeem:(BOOL)redeem_ {
    
    self.reward = reward_;
    self.redeem = redeem_;
    PFObject *vendor = [[GameUtils instance] getVendor:((PFObject *)[self.reward objectForKey:@"vendor"]).objectId];
    
    PFFile *imageFile = [self.reward objectForKey:@"image"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:[imageFile getData]];
        self.icon.image = image;
    }];
    self.businessNameLabel.text = [vendor objectForKey:@"name"];
    
    if (self.redeem) {
        self.progressParentView.hidden = YES;
        self.countDownParentView.hidden = NO;
        self.salesButton.hidden = YES;
        return;
    }

    self.progressParentView.hidden = NO;
    PFUser *user = [PFUser currentUser];
    NSMutableDictionary *progressMap = [user objectForKey:@"progressMap"];
    
    int target = [[self.reward objectForKey:@"target"] intValue];
    if (target > 1) {
        self.progressParentView.hidden = NO;
        self.salesButton.hidden = YES;

        int progress = 0;
        if ([[self.reward className] isEqualToString:@"Reward"]) {
            if ([progressMap objectForKey:self.reward.objectId] != nil) {
                progress = MIN([[[progressMap objectForKey:reward.objectId] objectForKey:@"Count"] intValue], target);
            }
        } else if ([self.reward.className isEqualToString:@"PointReward"]) {
            progress = MIN([[user objectForKey:@"rewardcatPoints"] intValue], target);
        }
        
        if (progress < 0) {
            progress = 0;
        }
        
        if (progress > target) {
            progress = target;
        }
        
        if (progress < target) {
            NSString *progressText = [NSString stringWithFormat:@"%d / %d", progress, target];
            [self.redeemButton setTitle:progressText forState:UIControlStateNormal];
            self.redeemButton.userInteractionEnabled = NO;
        } else {
            [self.redeemButton setTitle:@"Redeem Now!" forState:UIControlStateNormal];
            self.redeemButton.userInteractionEnabled = YES;
            [self.redeemButton setBackgroundImage:[UIImage imageNamed:@"barbigclick"] forState:UIControlStateHighlighted];
        }
        CGFloat progressWidth = MIN(self.progressSubParentView.frame.size.width * (float)progress / (float)target, self.progressSubParentView.frame.size.width);
        self.redeemButton.titleLabel.textAlignment = UITextAlignmentCenter;
        self.progressView.frame = CGRectMake(self.progressView.frame.origin.x,
                                             self.progressView.frame.origin.y,
                                             progressWidth,
                                             self.progressView.frame.size.height);
    } else {
        self.progressParentView.hidden = YES;
        self.salesButton.hidden = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)redeemButtonClicked:(id)sender {
    NSTimeInterval redeemTimeLength = [[self.reward objectForKey:@"redeemTimeLength"] doubleValue];
    [GameUtils showRedeemConfirmationWithTime:redeemTimeLength delegate:self];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"]) {
        [self setUpWithReward:self.reward redeem:YES];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.reward.objectId, @"rewardID", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startRedeemReward" object:nil userInfo:dictionary];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [reward release], reward = nil;
    [icon release], icon = nil;
    [progressParentView release], progressParentView = nil;
    [progressView release], progressView = nil;
    [redeemButton release], redeemButton = nil;
    [countDownParentView release], countDownParentView = nil;
    [countDownLabel release], countDownLabel = nil;
    [businessNameLabel release], businessNameLabel = nil;
    [super dealloc];
}

@end
