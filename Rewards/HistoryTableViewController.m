//
//  HistoryTableViewController.m
//  RewardCat
//
//  Created by Chang Liu on 2013-01-28.
//
//

#import "HistoryTableViewController.h"
#import "GameUtils.h"
#import "HistoryTableViewCell.h"
#import "LoadMoreTableViewCell.h"

@interface HistoryTableViewController ()

@end

@implementation HistoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (!self) {
        return self;
    }
    self.title = @"History";
    self.parseClassName = @"Transaction";
    self.objectsPerPage = 15;
    self.loadingViewEnabled = YES;
    self.tableView.tableHeaderView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([GameUtils instance].hasUserUpdatedForTransaction) {
        [GameUtils instance].hasUserUpdatedForTransaction = NO;
        [self loadObjects];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    if ([PFUser currentUser]) {
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query orderByDescending:@"createdAt"];
    } else {
        query = nil;
    }
    return query;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"HistoryTableViewCell";
    
    HistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    NSString *message;
    NSString *vendorName = [[GameUtils.instance getVendor:((PFObject *)[object objectForKey:@"vendor"]).objectId] objectForKey:@"name"];
    if ([[object objectForKey:@"activityType"] isEqualToString:@"Scanned Reward"]) {
        message = [NSString stringWithFormat:@"Scanned for \"%@\" at %@", [object objectForKey:@"rewardDescription"], vendorName];
    } else if ([[object objectForKey:@"activityType"] isEqualToString:@"Redeemed PointReward"] ||
               [[object objectForKey:@"activityType"] isEqualToString:@"Redeemed Reward"]) {
        message = [NSString stringWithFormat:@"Redeemed for \"%@\" at %@", [object objectForKey:@"rewardDescription"], vendorName];
    } else if ([[object objectForKey:@"activityType"] isEqualToString:@"Facebook Invite Friends"]) {
        message = [NSString stringWithFormat:@"Thanks for inviting %@ friends! Go to the Coins tab to start redeeming your rewards!",
                   [object objectForKey:@"rewardcatPointsDelta"]];
    } else if ([[object objectForKey:@"activityType"] isEqualToString:@"Bonus Coins"]) {
        message = [NSString stringWithFormat:@"Thanks for using RewardCat! Go to the Coins tab to start redeeming your rewards!"];
    } else {
        message = [NSString stringWithFormat:@"Thanks for signing up! Go to the Coins tab to start redeeming your rewards!"];
    }

    [cell setUpWithCoin:[[object objectForKey:@"rewardcatPointsDelta"] intValue]
                  stamp:[[object objectForKey:@"rewardDelta"] intValue]
                message:message
                   time:[object.createdAt timeIntervalSince1970]];

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
    return 80;
}

- (float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView new] autorelease];
}

@end