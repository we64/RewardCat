//
//  RewardsTableViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-09-29.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardsTableViewController.h"
#import "RewardsTableViewCell.h"
#import <Parse/Parse.h>

@interface RewardsTableViewController ()

@property (nonatomic) CGFloat cellHeight;

@end

@implementation RewardsTableViewController

@synthesize cellHeight;

- (id)init
{
    self = [super initWithClassName:@"Reward"];
    if (!self) {
        return self;
    }
    RewardsTableViewCell *cell = [[[RewardsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
    self.cellHeight = cell.frame.size.height;
    self.objectsPerPage = ceil(self.view.frame.size.height / self.cellHeight);
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
    
    RewardsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RewardsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.indexInTable = indexPath.row;
    
    PFUser *user = [PFUser currentUser];
    NSMutableDictionary *progressMap = [user objectForKey:@"progressMap"];
    
    int progress = 0;
    if ([progressMap objectForKey:object.objectId]) {
        progress = [[progressMap objectForKey:object.objectId] intValue];
    }
    
    NSDictionary *description = [object objectForKey:@"description"];
    PFFile *imageFile = [object objectForKey:@"image"];
    cell.imageView.image = nil;
    int indexInTable = cell.indexInTable;
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *errer) {
        UIImage *image = [UIImage imageWithData:[imageFile getData]];
        if (indexInTable == cell.indexInTable) {
            cell.imageView.image = image;
        }
    }];
    cell.textLabel.text = [description objectForKey:@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:[description objectForKey:@"description"], progress];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellHeight;
}

@end
