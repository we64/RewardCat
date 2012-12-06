//
//  PointRewardsTableViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-11-10.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "PointRewardsTableViewController.h"
#import "PointRewardsTableViewCell.h"
#import "LoadMoreTableViewCell.h"
#import "DetailViewController.h"
#import "PointsTableViewCell.h"

@interface PointRewardsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation PointRewardsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (!self) {
        return self;
    }
    self.title = @"Points";
    self.className = @"PointReward";
    self.objectsPerPage = 8;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"shouldUpdatePointsRewardList" object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [self refresh];
}

- (void)refresh {
    [super loadObjects];
}

- (void)loadObjects {
    self.view.userInteractionEnabled = NO;
    [super loadObjects];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    self.view.userInteractionEnabled = YES;
}

#pragma mark - Table view data source

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:@"target"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView cellForRowAtIndexPath:indexPath checkingForHeight:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath checkingForHeight:(BOOL)checkingForHeight {
    
    if (indexPath.section != 0 || indexPath.row >= self.objects.count) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    if (![object respondsToSelector:@selector(className)] || ![object.className isEqualToString:@"PointReward"]) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    static NSString *CellIdentifier = @"PointRewardsTableViewCell";
    
    PointRewardsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if (checkingForHeight) {
        [cell setUpWithItemForHeight:object];
    } else {
        cell.indexInTable = indexPath.row;
        cell.pointRewardsTableViewController = self;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section > 0) {
        return nil;
    }
    
    static NSString *CellIdentifier = @"PointsTableViewCell";
    
    PointsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSNumber *pointsNumber = [[PFUser currentUser] objectForKey:@"rewardcatPoints"];
    if (pointsNumber) {
        cell.pointsLabel.text = [[[PFUser currentUser] objectForKey:@"rewardcatPoints"] stringValue];
    } else {
        cell.pointsLabel.text = @"0";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self tableView:tableView viewForHeaderInSection:section].frame.size.height;
}

@end
