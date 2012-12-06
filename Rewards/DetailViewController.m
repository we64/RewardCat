//
//  DetailViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-10-28.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailHeaderCell.h"
#import "DetailInfoCell.h"
#import "DetailDescriptionCell.h"

@interface DetailViewController ()

@property (nonatomic) NSTimeInterval countDownStartTime;
@property (nonatomic, retain) NSTimer *countDownTimer;
@property (nonatomic) NSInteger redeemTime;
@property (nonatomic) BOOL isVisible;

@end

@implementation DetailViewController

@synthesize reward;
@synthesize redeem;
@synthesize detailTableView;
@synthesize countDownStartTime;
@synthesize countDownTimer;
@synthesize redeemTime;
@synthesize isVisible;

- (id)initWithReward:(PFObject *)reward_ redeem:(BOOL)redeem_ {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.reward = reward_;
    self.redeem = redeem_;
    self.redeemTime = [[self.reward objectForKey:@"redeemTimeLength"] intValue];
    self.title = @"Detail";
    self.isVisible = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redeemTimerExpired:) name:@"redeemTimerExpired" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redeemReward) name:@"startRedeemReward" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRedeemCountDown:) name:@"startRedeemCountDown" object:nil];
    
    return self;
}

- (void)redeemTimerExpired:(NSNotification *)notification {
    NSString *rewardId = [notification.userInfo objectForKey:@"rewardID"];
    if (![self.reward.objectId isEqualToString:rewardId]) {
        return;
    }
    [self.countDownTimer invalidate];
    if (self.isVisible) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section <= 0) {
        NSArray *contactInfo = [self.reward objectForKey:@"contactInfo"];
        return contactInfo.count + 2;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView cellForRowAtIndexPath:indexPath checkingForHeight:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath checkingForHeight:(BOOL)checkingForHeight {
    if (indexPath.section != 0) {
        return 0;
    }
    
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"DetailHeaderCell";
        
        DetailHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (!checkingForHeight) {
                [cell setUpWithReward:self.reward redeem:self.redeem];
            }
        }
        return cell;
    }
    
    if (indexPath.row == 1) {
        static NSString *CellIdentifier = @"DetailDescriptionCell";
        
        DetailDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
            [cell setDetailLabelTextAndAdjustCellHeight:[[self.reward objectForKey:@"description"] objectForKey:@"longDescription"]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        return cell;
    }

    NSArray *contactInfo = [self.reward objectForKey:@"contactInfo"];
    int numberOfRowsInSection = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row >= 2 && indexPath.row < numberOfRowsInSection) {
        static NSString *CellIdentifier = @"DetailInfoCell";
        
        DetailInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        int contactInfoIndex = indexPath.row - 2;
        NSDictionary *contactInfoDictionary = [contactInfo objectAtIndex:contactInfoIndex];
        cell.title.text = [contactInfoDictionary objectForKey:@"title"];
        [cell setInfoLabelTextAndAdjustCellHeight:[contactInfoDictionary objectForKey:@"info"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!checkingForHeight) {
            if (indexPath.row == 0) {
                cell.topBorder.image = [UIImage imageNamed:@"tabletop.png"];
            } else {
                cell.topBorder.image = [UIImage imageNamed:@"rowtop.png"];
            }
            
            if (indexPath.row == numberOfRowsInSection - 1) {
                cell.bottomBorder.image = [UIImage imageNamed:@"tablebottom.png"];
            } else {
                cell.bottomBorder.image = [UIImage imageNamed:@"rowbottom.png"];
            }
            
            cell.action = [NSURL URLWithString:[contactInfoDictionary objectForKey:@"action"]];
            BOOL isMapUrl = [[cell.action absoluteString] rangeOfString:@"maps.google"].location != NSNotFound;
            if (isMapUrl) {
                cell.coordinates = [contactInfoDictionary objectForKey:@"coordinates"];
                cell.businessName = [[self.reward objectForKey:@"description"] objectForKey:@"title"];
            }
        }
        
        cell.icon.image = [UIImage imageNamed:[contactInfoDictionary objectForKey:@"icon"]];
        
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView: tableView cellForRowAtIndexPath:indexPath checkingForHeight:YES].frame.size.height;
}

- (void)startRedeemCountDown:(NSNotification *)notification {
    NSString *rewardId = [notification.userInfo objectForKey:@"rewardID"];
    if (![self.reward.objectId isEqualToString:rewardId]) {
        return;
    }
    self.countDownStartTime = [[NSDate date] timeIntervalSince1970];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                           target:self
                                                         selector:@selector(updateCountDown)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)updateCountDown {
    NSTimeInterval timeRemaining = self.countDownStartTime + self.redeemTime - [[NSDate date] timeIntervalSince1970];
    if (timeRemaining > 0) {
        int seconds = (int)floor(timeRemaining) % 60;
        int minutes = (int)floor(timeRemaining / 60);
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%d:%02d", minutes, seconds], @"text", self.reward.objectId, @"rewardID", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateCountDownLabel" object:nil userInfo:dictionary];
    } else {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.reward.objectId, @"rewardID", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"redeemTimerExpired" object:nil userInfo:dictionary];
    }
}

- (void)redeemReward {
    self.redeem = YES;
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.reward.objectId, @"rewardID",
                                [self.reward objectForKey:@"target"], @"target",
                                self.reward.className, @"rewardType", nil];
    [PFCloud callFunctionInBackground:@"redeemReward" withParameters:dictionary block:^(id result, NSError *error) {
        if (!error) {
            NSString *className = [dictionary objectForKey:@"rewardType"];
            [[PFUser currentUser] refresh];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startRedeemCountDown" object:nil userInfo:dictionary];
            if ([className isEqualToString:@"Reward"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdateRewardList" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdatePointsRewardList" object:nil];
            } else if ([className isEqualToString:@"PointReward"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdatePointsRewardList" object:nil];
            }
        } else {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Unable to redeem"
                                                             message:[[error userInfo] objectForKey:@"error"]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
            [alert show];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.redeem && self.countDownStartTime == 0) {
        [self.countDownTimer invalidate];
        [self redeemReward];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isVisible = NO;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [countDownTimer invalidate];
    [countDownTimer release], countDownTimer = nil;
    [detailTableView release], detailTableView = nil;
    [reward release], reward = nil;
    [super dealloc];
}

@end
