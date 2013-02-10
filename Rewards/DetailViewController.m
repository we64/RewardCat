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
#import "GameUtils.h"
#import "Flurry.h"
#import <CoreLocation/CoreLocation.h>

@interface DetailViewController ()

@property (nonatomic) NSTimeInterval countDownStartTime;
@property (nonatomic, retain) NSTimer *countDownTimer;
@property (nonatomic) NSInteger redeemTime;
@property (nonatomic) BOOL redeem;
@property (nonatomic, retain) NSArray *contactInfo;
@property (nonatomic, retain) CLLocation *location;

@end

@implementation DetailViewController

@synthesize reward;
@synthesize redeem;
@synthesize detailTableView;
@synthesize countDownStartTime;
@synthesize countDownTimer;
@synthesize redeemTime;
@synthesize contactInfo;
@synthesize location;

- (id)initWithReward:(PFObject *)reward_ {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.reward = reward_;
    self.redeemTime = [[self.reward objectForKey:@"redeemTimeLength"] intValue];
    self.title = @"Detail";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redeemTimerExpired:) name:@"redeemTimerExpired" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redeemReward:) name:@"startRedeemReward" object:nil];
    
    return self;
}

- (void)redeemTimerExpired:(NSNotification *)notification {
    NSString *rewardId = [notification.userInfo objectForKey:@"rewardID"];
    if (![self.reward.objectId isEqualToString:rewardId]) {
        return;
    }
    [self.countDownTimer invalidate];
    if ([self.reward.className isEqualToString:@"Reward"]) {
        [[GameUtils instance].rewardRedeemStartTime removeObjectForKey:self.reward.objectId];
    } else if ([self.reward.className isEqualToString:@"PointReward"]) {
        [[GameUtils instance].pointRewardRedeemStartTime removeObjectForKey:self.reward.objectId];
    }
}

- (void)redeemReward:(NSNotification *)notification {
    NSString *rewardId = [notification.userInfo objectForKey:@"rewardID"];
    if (![self.reward.objectId isEqualToString:rewardId]) {
        return;
    }
    self.redeem = YES;
    [Flurry logEvent:[@"action_redeem_" stringByAppendingString:self.reward.className]];

    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.reward.objectId, @"rewardID",
                                [self.reward objectForKey:@"target"], @"target",
                                self.reward.className, @"rewardType", nil];    
    [GameUtils showProcessing];
    [PFCloud callFunctionInBackground:@"redeemReward" withParameters:dictionary block:^(id result, NSError *error) {
        
        [GameUtils hideProgressing];
        if (!error) {
            [GameUtils refreshCurrentUser];
            [self startRedeemCountDown];

            /*NSMutableDictionary *postParams =
            [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
             @"Testing", @"message",
              @"120272904656135", @"place",
             nil] autorelease];
            PF_FBRequest *req = [[PF_FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:@"me/feed" parameters:postParams HTTPMethod:@"POST"];
            
            [req startWithCompletionHandler:^(PF_FBRequestConnection *connection, id result, NSError *error) {
                NSLog(@"%@", result);
            }];*/
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

- (void)startRedeemCountDown {
    if (self.countDownStartTime <= 0) {
        self.countDownStartTime = [[NSDate date] timeIntervalSince1970];
        if ([self.reward.className isEqualToString:@"Reward"]) {
            [[GameUtils instance].rewardRedeemStartTime setValue:[NSNumber numberWithDouble:self.countDownStartTime] forKey:self.reward.objectId];
        } else if ([self.reward.className isEqualToString:@"PointReward"]) {
            [[GameUtils instance].pointRewardRedeemStartTime setValue:[NSNumber numberWithDouble:self.countDownStartTime] forKey:self.reward.objectId];
        }
    }
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                           target:self
                                                         selector:@selector(updateCountDown)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section <= 0) {
        return self.contactInfo.count + 3;
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
        [self updateCountDown];
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

    // for loading info cells
    static NSString *CellIdentifier = @"DetailInfoCell";
    DetailInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    int numberOfRowsInSection = [self tableView:tableView numberOfRowsInSection:indexPath.section];

    if (indexPath.row >= 2 && indexPath.row < numberOfRowsInSection - 1) {

        int contactInfoIndex = indexPath.row - 2;
        NSDictionary *contactInfoDictionary = [self.contactInfo objectAtIndex:contactInfoIndex];
        cell.title.text = [contactInfoDictionary objectForKey:@"title"];
        [cell setInfoLabelTextAndAdjustCellHeight:[contactInfoDictionary objectForKey:@"info"]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.icon.image = [UIImage imageNamed:[contactInfoDictionary objectForKey:@"icon"]];
        PFObject *vendor = [[GameUtils instance] getVendor:((PFObject *)[self.reward objectForKey:@"vendor"]).objectId];
        
        if (!checkingForHeight) {
            cell.action = [NSURL URLWithString:[contactInfoDictionary objectForKey:@"action"]];
            BOOL isMapUrl = [[cell.action absoluteString] rangeOfString:@"maps.google"].location != NSNotFound;
            if (isMapUrl) {
                cell.coordinate = [self.location coordinate];
                cell.businessName = [vendor objectForKey:@"name"];
            }
        }
    } else {
        // expireDate section
        cell.title.text = @"Expire Date:";
        [cell setInfoLabelTextAndAdjustCellHeight:[[GameUtils instance].expireDateFormatter stringFromDate:[self.reward objectForKey:@"expireDate"]]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
    }

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

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView: tableView cellForRowAtIndexPath:indexPath checkingForHeight:YES].frame.size.height;
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

- (void)viewDidLoad {
    [super viewDidLoad];

    // get vendor information if not exist
    if (self.contactInfo == nil) {
        PFObject *vendor = [[GameUtils instance] getVendor:((PFObject *)[self.reward objectForKey:@"vendor"]).objectId];
        self.contactInfo = [vendor objectForKey:@"contactInfo"];
        PFGeoPoint *point = (PFGeoPoint *)[vendor objectForKey:@"location"];
        self.location = [[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude];
    }

    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[[GameUtils instance] getVendor:((PFObject *)[self.reward objectForKey:@"vendor"]).objectId] objectForKey:@"name"], @"vendorName",
                                [[self.reward objectForKey:@"description"] objectForKey:@"longDescription"], @"rewardDesc",
                                self.reward.className, @"rewardType", nil];
    // set redeem state
    if ([self.reward.className isEqualToString:@"Reward"]) {
        self.countDownStartTime = [[[GameUtils instance].rewardRedeemStartTime objectForKey:self.reward.objectId] doubleValue];
        [Flurry logEvent:@"page_view_details_rewards" withParameters:dictionary];
    } else if ([self.reward.className isEqualToString:@"PointReward"]) {
        self.countDownStartTime = [[[GameUtils instance].pointRewardRedeemStartTime objectForKey:self.reward.objectId] doubleValue];
        [Flurry logEvent:@"page_view_details_coins" withParameters:dictionary];
    }

    if (self.countDownStartTime > 0) {
        self.redeem = YES;
    } else {
        self.redeem = NO;
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [countDownTimer invalidate];
    [location release], location = nil;
    [countDownTimer release], countDownTimer = nil;
    [detailTableView release], detailTableView = nil;
    [reward release], reward = nil;
    [contactInfo release], contactInfo = nil;
    [super dealloc];
}

@end
