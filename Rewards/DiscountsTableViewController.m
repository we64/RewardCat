//
//  DiscountsTableViewController.m
//  RewardCat
//
//  Created by Chang Liu on 2013-02-17.
//
//

#import "DiscountsTableViewController.h"
#import "DiscountsViewController.h"
#import "LocationManager.h"
#import "DiscountsTableViewCell.h"
#import "GameUtils.h"
#import "LoadMoreTableViewCell.h"
#import "AdsUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "CategoryViewController.h"
#import "Logger.h"

@interface DiscountsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) CategoryViewController *categoryViewController;
@property (nonatomic) BOOL shouldRefresh;

@end

@implementation DiscountsTableViewController

@synthesize categoryViewController;
@synthesize shouldRefresh;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (!self) {
        return self;
    }
    self.title = @"Discounts";
    self.parseClassName = @"Discount";
    self.objectsPerPage = 20;
    self.loadingViewEnabled = YES;
    self.shouldRefresh = NO;

    self.tableView.separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAds) name:@"adsUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocationRefreshed) name:@"currentLocationRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjectsByCategory) name:@"dismissCategoryView" object:nil];

    return self;
}

- (void)loadObjectsByCategory {
    if ([GameUtils instance].currentCategory &&
        ![(NSNumber *)[[GameUtils instance].currentCategory objectForKey:@"showAll"] intValue]) {
        self.title = [[GameUtils instance].currentCategory objectForKey:@"name"];
    } else {
        self.title = @"Discounts";
    }

    self.shouldRefresh = YES;
    [self loadObjects];
}

- (void)currentLocationRefreshed {
    self.shouldRefresh = YES;

    // if screen is visible, then reload objects immediately
    if (self.isViewLoaded && self.view.window) {
        [self loadObjects];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // if screen is visible, then reload objects immediately
    if (self.shouldRefresh) {
        [self loadObjects];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Categories"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showCategories)] autorelease];
    [self.navigationItem setHidesBackButton:YES animated:YES];
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

- (void)showCategories {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    self.navigationController.navigationBarHidden = NO;

    self.categoryViewController = [[[CategoryViewController alloc] initWithNibName:@"CategoryViewController" bundle:nil] autorelease];
    [self.navigationController pushViewController:self.categoryViewController animated:NO];
}

- (void)updateAds {
    if ([GameUtils instance].tabBarController.selectedViewController.class != [DiscountsViewController class]) {
        return;
    }
    if ([AdsUtils instance].allAds.count) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
    }
}

#pragma mark - Table view data source

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    PFQuery *subQuery = [PFQuery queryWithClassName:@"Vendor"];
    
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

    [query whereKey:@"expireDate" greaterThanOrEqualTo:[GameUtils getToday]];
    [query whereKey:@"discountType" equalTo:[NSNumber numberWithInt:0]];
    if ([GameUtils instance].currentCategory &&
        ![(NSNumber *)[[GameUtils instance].currentCategory objectForKey:@"showAll"] intValue]) {
        [subQuery whereKey:@"category" equalTo:[GameUtils instance].currentCategory];
        [query whereKey:@"vendor" matchesQuery:subQuery];
    }
    
    if ([LocationManager allowLocationService]) {
        [query whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLocation:[LocationManager sharedSingleton].locationManager.location]];
    } else {
        [query orderByDescending:@"createdAt"];
    }
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView cellForRowAtIndexPath:indexPath checkingForHeight:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath checkingForHeight:(BOOL)checkingForHeight {
    static NSString *CellIdentifier = @"DiscountsTableViewCell";

    if (indexPath.section <= 0) {
        DiscountsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.indexInTable = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        cell.discountsTableViewController = self;
        [cell updateAdForHeight:checkingForHeight];
        if (!checkingForHeight) {
            [Logger.instance logAdImpression:cell.item];
            NSLog(@"Ads showing");
        }
        return cell;
    }
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
    if (indexPath.section == 0 && indexPath.row >= self.objects.count) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }

    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    if (![object respondsToSelector:@selector(className)] || ![object.parseClassName isEqualToString:@"Discount"]) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    DiscountsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.indexInTable = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    cell.discountsTableViewController = self;
    
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

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section <= 0) {
        if ([AdsUtils instance].allAds.count) {
            return 1;
        } else {
            return 0;
        }
    }
    int numOfRows = [super tableView:tableView numberOfRowsInSection:section];
    return numOfRows;
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.objects.count && indexPath.section > 0) {
        // load more cell height
        return 35.0f;
    } else if (indexPath.row >= self.objects.count && indexPath.section <= 0) {
        // if only ads shows up, make sure it is 80 in size
        return 80.0f;
    }
    
    NSString *descriptionText = [[[self.objects objectAtIndex:[indexPath row]] objectForKey:@"description"] objectForKey:@"description"];
    
    // the default width of the label is 184
    CGSize constraint = CGSizeMake(184.0f, 20000.0f);
    CGSize descriptionSize = [descriptionText sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    // the default height of the cell is 80
    // the default height of the rest is 55
    CGFloat height = MAX(descriptionSize.height + 55.0f, 80.0f);
    
    return height;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [categoryViewController release], categoryViewController = nil;
    [super dealloc];
}

@end
