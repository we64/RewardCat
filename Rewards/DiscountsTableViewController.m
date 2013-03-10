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

@interface DiscountsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation DiscountsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (!self) {
        return self;
    }
    self.title = @"Discounts";
    self.className = @"Discount";
    self.objectsPerPage = 20;
    self.loadingViewEnabled = YES;
    
    self.tableView.separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAds) name:@"adsUpdated" object:nil];

    return self;
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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)updateAds {
    if ([GameUtils instance].tabBarController.selectedViewController.class != [DiscountsViewController class]) {
        return;
    }
    if ([AdsUtils instance].allAds.count) {
        // TODO: we always randomly crash on this line
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
    }
}

#pragma mark - Table view data source

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60 * 60 * 24;  // One day, in seconds.

    [query whereKey:@"expireDate" greaterThanOrEqualTo:[GameUtils getToday]];
    [query whereKey:@"discountType" equalTo:[NSNumber numberWithInt:0]];
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
            PFObject *logger = [PFObject objectWithClassName:@"Log"];
            [logger setObject:[PFUser currentUser] forKey:@"user"];
            [logger setObject:cell.item forKey:@"discount"];
            [logger saveEventually];
            NSLog(@"Ads showing");
        }
        return cell;
    }
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
    if (indexPath.section == 0 && indexPath.row >= self.objects.count) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }

    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    if (![object respondsToSelector:@selector(className)] || ![object.className isEqualToString:@"Discount"]) {
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
    section--;
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:(UITableView *)tableView cellForRowAtIndexPath:indexPath checkingForHeight:YES].frame.size.height;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView new] autorelease];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
