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
#import "LocationManager.h"
#import "GameUtils.h"

@interface PointRewardsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) int objectsPerCell;
@property (nonatomic, retain) UIBarButtonItem *sortToggleButton;
@property (nonatomic) BOOL byDistance;

@end

@implementation PointRewardsTableViewController

@synthesize objectsPerCell;
@synthesize sortToggleButton;
@synthesize byDistance;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (!self) {
        return self;
    }
    self.title = @"Coins";
    self.className = @"PointReward";
    self.objectsPerPage = 16;

    // set toggle button correctly
    if ([LocationManager allowLocationService]) {
        self.byDistance = YES;
        sortToggleButton = [[[UIBarButtonItem alloc] initWithTitle:@"By Cost"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(sortToggle)] autorelease];
    } else {
        self.byDistance = NO;
        sortToggleButton = [[[UIBarButtonItem alloc] initWithTitle:@"By Distance"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(sortToggle)] autorelease];
    }

    static NSString *CellIdentifier = @"PointRewardsTableViewCell";
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
    PointRewardsTableViewCell *cell = [nib objectAtIndex:0];
    self.objectsPerCell = cell.detailsButtons.count;
    self.tableView.separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = sortToggleButton;
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

- (void)sortToggle {
    if (self.byDistance) {
        self.byDistance = NO;
        [sortToggleButton setTitle:@"By Distance"];
        [self loadObjects];
    } else {
        if ([LocationManager allowLocationService]) {
            self.byDistance = YES;
            [sortToggleButton setTitle:@"By Cost"];
            [self loadObjects];
        } else {
            // show alert
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Current Location Not Available"
                                                             message:@"To see distance info, please enable Location Services for RewardCat in your iPhone Settings."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
            [alert show];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([GameUtils instance].hasUserUpdatedForCoin) {
        [self loadObjects];
        [GameUtils instance].hasUserUpdatedForCoin = NO;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [sortToggleButton release], sortToggleButton = nil;
    [super dealloc];
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

    [query whereKey:@"expireDate" greaterThanOrEqualTo:[GameUtils getToday]];
    if (self.byDistance) {
        if ([LocationManager allowLocationService]) {
            [query whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLocation:[LocationManager sharedSingleton].locationManager.location]];
        } else {
            self.byDistance = NO;
            [sortToggleButton setTitle:@"By Distance"];
            [query orderByAscending:@"target"];
        }
    } else {
        [query orderByAscending:@"target"];
    }
    
    return query;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int originalCount = [super tableView:tableView numberOfRowsInSection:section];
    if (section == 0) {
        return [self numberOfObjectRows] + (originalCount - self.objects.count);
    } else {
        return originalCount;
    }
}

- (int)numberOfObjectRows {
    return (self.objects.count + self.objectsPerCell - 1) / self.objectsPerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PointRewardsTableViewCell";
    PointRewardsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if (indexPath.section != 0) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else if (indexPath.row >= [self numberOfObjectRows]) {
        int newRow = self.objects.count;
        return [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:newRow inSection:indexPath.section]];
    }
    
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *indicesInTable = [NSMutableArray array];
    for (int i = 0; i < self.objectsPerCell; i++) {
        int indexInTable = indexPath.row * self.objectsPerCell + i;
        if (indexInTable > self.objects.count - 1) {
            break;
        }
        PFObject *object = [self.objects objectAtIndex:indexInTable];
        if (![object respondsToSelector:@selector(className)] || ![object.className isEqualToString:@"PointReward"]) {
            return [super tableView:tableView cellForRowAtIndexPath:indexPath];
        }
        [objects addObject:object];
        [indicesInTable addObject:[NSNumber numberWithInt:indexInTable]];
    }
    
    cell.indicesInTable = indicesInTable;
    cell.pointRewardsTableViewController = self;
    [cell setUpWithItems:objects];
    
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
    return [self tableView:(UITableView *)tableView cellForRowAtIndexPath:indexPath].frame.size.height;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row >= [self numberOfObjectRows]) {
        int newRow = self.objects.count;
        [super tableView:tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:newRow inSection:indexPath.section]];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row >= [self numberOfObjectRows]) {
        int newRow = self.objects.count;
        [super tableView:tableView didDeselectRowAtIndexPath:[NSIndexPath indexPathForRow:newRow inSection:indexPath.section]];
    } else {
        [super tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
}

@end
