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
    self.className = @"Transaction";
    self.objectsPerPage = 15;
    self.loadingViewEnabled = YES;
    self.tableView.tableHeaderView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"refreshHistoryList" object:nil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    PFQuery *query = [PFQuery queryWithClassName:self.className];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
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
    NSString *vendorName = [[[GameUtils instance] getVendor:((PFObject *)[object objectForKey:@"vendor"]).objectId] objectForKey:@"name"];
    if ([[object objectForKey:@"activityType"] isEqualToString:@"Scanned Reward"]) {
        message = [NSString stringWithFormat:@"Scanned for \"%@\" at %@", [object objectForKey:@"rewardDescription"], vendorName];
    } else if ([[object objectForKey:@"activityType"] isEqualToString:@"Redeemed PointReward"] ||
               [[object objectForKey:@"activityType"] isEqualToString:@"Redeemed Reward"]) {
        message = [NSString stringWithFormat:@"Redeemed for \"%@\" at %@", [object objectForKey:@"rewardDescription"], vendorName];
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
    return [self tableView:(UITableView *)tableView cellForRowAtIndexPath:indexPath].frame.size.height;
}

@end