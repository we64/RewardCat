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
#import "LocationManager.h"
#import "GameUtils.h"

@interface RewardsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UIBarButtonItem *toggleButton;
@property (nonatomic) BOOL myRewards;
//@property (nonatomic, retain) NSMutableDictionary *cellHeights;

@end

@implementation RewardsTableViewController

@synthesize toggleButton;
//@synthesize cellHeights;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (!self) {
        return self;
    }
//    self.cellHeights = [NSMutableDictionary dictionary];
    self.title = @"Rewards";
    self.className = @"Reward";
    self.objectsPerPage = 20;
    self.loadingViewEnabled = YES;
    self.myRewards = NO;
    self.toggleButton = [[UIBarButtonItem alloc] initWithTitle:@"My Rewards"
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(showMyRewards)];

    self.tableView.separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    return self;
}

- (void)viewDidLoad {
    self.navigationItem.leftBarButtonItem = self.toggleButton;
    [super viewDidLoad];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [cellHeights release], cellHeights = nil;
    [toggleButton release], toggleButton = nil;
    [super dealloc];
}

- (void)showMyRewards {
    self.myRewards = !self.myRewards;
    if (self.myRewards) {
        [self.toggleButton setTitle:@"All Rewards"];
    } else {
        [self.toggleButton setTitle:@"My Rewards"];
    }
    [self loadObjects];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([GameUtils instance].hasUserUpdatedForReward) {
        [self loadObjects];
        [GameUtils instance].hasUserUpdatedForReward = NO;
    }
}

- (void)loadNextPage {
    [GameUtils showProcessing];
    [super loadNextPage];
}

- (void)loadObjects {
    [GameUtils showProcessing];
    [super loadObjects];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [GameUtils hideProgressing];
}

#pragma mark - Table view data source

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60 * 60 * 24;  // One day, in seconds.

    if (self.myRewards) {
        PFUser *user = [PFUser currentUser];
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:[user objectForKey:@"progressMap"]];
        
        [[user objectForKey:@"progressMap"] enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            if ([(NSNumber *)[obj objectForKey:@"Count"] intValue] == 0) {
                [result removeObjectForKey:key];
            }
        }];
        
        [query whereKey:@"objectId" containedIn:[result allKeys]];
    }
    
    [query whereKey:@"expireDate" greaterThanOrEqualTo:[GameUtils getToday]];
    [query whereKey:@"target" greaterThan:[NSNumber numberWithInt:0]];
    if ([LocationManager allowLocationService]) {
        [query whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLocation:[LocationManager sharedSingleton].locationManager.location]];
    } else {
        [query orderByDescending:@"createdAt"];
    }
    
    return query;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section];
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

    if (indexPath.row >= self.objects.count) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }

    return [self tableView:(UITableView *)tableView cellForRowAtIndexPath:indexPath checkingForHeight:YES].frame.size.height;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView new] autorelease];
}

@end
