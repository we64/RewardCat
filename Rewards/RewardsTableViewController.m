//
//  RewardsTableViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-09-29.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardsTableViewController.h"

@interface RewardsTableViewController ()

@end

@implementation RewardsTableViewController

- (id)init
{
    self = [super initWithClassName:@"Reward"];
    if (!self) {
        return self;
    }
    self.objectsPerPage = 1;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    PFUser *user = [PFUser currentUser];
    NSMutableDictionary *progressMap = [user objectForKey:@"progressMap"];
    
    int progress = 0;
    if ([progressMap objectForKey:object.objectId]) {
        progress = [[progressMap objectForKey:object.objectId] intValue];
    }
    
    NSDictionary *description = [object objectForKey:@"description"];
    cell.textLabel.text = [description objectForKey:@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:[description objectForKey:@"description"], progress];
    
    return cell;
}

@end
