//
//  CategoryTableViewController.m
//  RewardCat
//
//  Created by Chang Liu on 2013-03-22.
//
//

#import "CategoryTableViewController.h"
#import "CategoryTableViewCell.h"
#import "GameUtils.h"

@interface CategoryTableViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation CategoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (!self) {
        return self;
    }
    self.className = @"Category";
    self.objectsPerPage = 15;
    self.loadingViewEnabled = YES;
    self.pullToRefreshEnabled = NO;
    
    return self;
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.className];

    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:@"sortOrder"];
    return query;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"CategoryTableViewCell";
    
    CategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSString *categoryName = [object objectForKey:@"name"];
    if (![GameUtils instance].currentCategory) {
        // rare case, if it is none, try to fetch it
        PFQuery *query = [PFQuery queryWithClassName:@"Category"];
        [query whereKey:@"showAll" equalTo:[NSNumber numberWithBool:YES]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [GameUtils instance].currentCategory = object;
        }];
    }
    if ([categoryName isEqualToString:[[GameUtils instance].currentCategory objectForKey:@"name"]]) {
        cell.selectedImageView.hidden = NO;
    } else {
        cell.selectedImageView.hidden = YES;
    }
    cell.categoryObject = object;
    cell.categoryNameLabel.text = categoryName;
    
    return cell;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
