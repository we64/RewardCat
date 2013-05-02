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
@property (nonatomic) BOOL shouldRefresh;

@end

@implementation RewardsTableViewController

@synthesize toggleButton;
@synthesize shouldRefresh;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (!self) {
        return self;
    }
    self.title = @"Loyalty Rewards";
    self.parseClassName = @"Reward";
    self.objectsPerPage = 20;
    self.loadingViewEnabled = YES;
    self.myRewards = NO;
    self.shouldRefresh = NO;
    self.toggleButton = [[UIBarButtonItem alloc] initWithTitle:@"My Rewards"
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(showMyRewards)];

    self.tableView.separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableShouldRefresh) name:@"currentLocationRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableShouldRefresh) name:@"currentUserRefreshed" object:nil];

    return self;
}

- (void)viewDidLoad {
    self.navigationItem.leftBarButtonItem = self.toggleButton;
    [super viewDidLoad];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    self.shouldRefresh = YES;
    [self loadObjects];
}

- (void)tableShouldRefresh {
    if (!self.shouldRefresh) {
        self.shouldRefresh = YES;
        
        // if screen is visible, then reload objects immediately
        if (self.isViewLoaded && self.view.window) {
            [self loadObjects];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.shouldRefresh) {
        [self loadObjects];
    }
}

- (void)loadNextPage {
    [GameUtils showProcessing];
    [super loadNextPage];
}

- (void)loadObjects {
    if (self.shouldRefresh) {
        [GameUtils showProcessing];
    }
    [super loadObjects];
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    [GameUtils hideProgressing];
    self.shouldRefresh = NO;
}

#pragma mark - Table view data source

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    return [self tableView:tableView cellForRowAtIndexPath:indexPath object:object checkingForHeight:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object checkingForHeight:(BOOL)checkingForHeight {
    
    static NSString *CellIdentifier = @"RewardsTableViewCell";
    RewardsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    cell.indexInTable = indexPath.row;
    cell.rewardsTableViewController = self;
    if (checkingForHeight) {
        [cell setUpWithItemForHeight:object];
    } else {
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
    
    [self loadNextPage];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.objects.count) {
        // load more cell height
        return 35.0f;
    }

    NSString *descriptionText = [[[self.objects objectAtIndex:[indexPath row]] objectForKey:@"description"] objectForKey:@"description"];
    PFObject *vendor = [GameUtils.instance getVendor:((PFObject *)[[self.objects objectAtIndex:[indexPath row]] objectForKey:@"vendor"]).objectId];
    NSString *vendorName = [vendor objectForKey:@"name"];

    // the default width of the label is 184
    CGSize constraint = CGSizeMake(184.0f, 20000.0f);
    CGSize descriptionSize = [descriptionText sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    CGSize vendorNameSize = [vendorName sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    // the default height of the cell is 80
    // the default height of the process bar with margin is 27
    // padding of 8 is to make sure the description is not right on top of the process bar, or else it would look weird
    CGFloat height = MAX(descriptionSize.height + vendorNameSize.height + 27.0f + 8.0f, 80.0f);
    
    return height;
}

@end
