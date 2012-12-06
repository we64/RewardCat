//
//  RewardsTableViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-09-29.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardsTableViewController.h"
#import "RewardsTableViewCell.h"
#import "LoadMoreTableViewCell.h"
#import "DetailViewController.h"



@interface RewardsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) int indexToHighlight;

@end

@implementation RewardsTableViewController

@synthesize indexToHighlight;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (!self) {
        return self;
    }
    self.title = @"Rewards";
    self.className = @"Reward";
    self.objectsPerPage = 8;
    self.indexToHighlight = -1;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"shouldUpdateRewardList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAndScrollToRewardId:) name:@"shouldUpdateRewardListWithReward" object:nil];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)refresh {
    [self loadObjects];
}

- (void)loadObjects {
    self.view.userInteractionEnabled = NO;
    [super loadObjects];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    self.view.userInteractionEnabled = YES;
}

- (void)refreshAndScrollToRewardId:(NSNotification *)notification {
    [self loadObjects];
    int index = 0;
    NSString *rewardId = [notification.userInfo objectForKey:@"rewardId"];
    for (PFObject *reward in self.objects) {
        if ([reward respondsToSelector:@selector(className)] && [reward.className isEqualToString:@"Reward"] && [reward.objectId isEqualToString:rewardId]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [((RewardsTableViewCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath]) highlight];
            self.indexToHighlight = index;
            return;
        }
        index++;
    }
}

#pragma mark - Table view data source

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:@"displayPriority"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView cellForRowAtIndexPath:indexPath checkingForHeight:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath checkingForHeight:(BOOL)checkingForHeight {
    
    if (indexPath.section == 0 && indexPath.row >= self.objects.count) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    if (![object respondsToSelector:@selector(className)] || ![object.className isEqualToString:@"Reward"]) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    static NSString *CellIdentifier = @"RewardsTableViewCell";
    
    RewardsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if (checkingForHeight) {
        [cell setUpWithItemForHeight:object];
    } else {
        if (indexPath.row == self.indexToHighlight) {
            self.indexToHighlight = -1;
            [cell highlight];
        } else {
            cell.highLightBackgroundView.alpha = 0;
        }
        
        cell.indexInTable = indexPath.row;
        cell.rewardsTableViewController = self;
        [cell setUpWithItem:object];
    }

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LoadMoreTableViewCell";
    
    LoadMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:(UITableView *)tableView cellForRowAtIndexPath:indexPath checkingForHeight:YES].frame.size.height;
}

@end
