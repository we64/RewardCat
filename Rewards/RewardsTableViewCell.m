//
//  RewardsTableViewCell.m
//  Rewards
//
//  Created by Chang Liu on 2012-10-07.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardsTableViewCell.h"
#import "DetailViewController.h"
#import "GameUtils.h"
#import "LocationManager.h"

@interface RewardsTableViewCell()

@end

@implementation RewardsTableViewCell

@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize distanceLabel;
@synthesize imageView;
@synthesize redeemButton;
@synthesize progressView;
@synthesize progressParentView;
@synthesize item;
@synthesize rewardsTableViewController;
@synthesize imageFile;
@synthesize indexInTable;
@synthesize imageContainerView;
@synthesize arrow;
@synthesize descriptionWidth;

- (void)setUpViews {
    self.imageView.clipsToBounds = YES;
    self.imageContainerView.clipsToBounds = NO;
    self.imageContainerView.backgroundColor = [UIColor clearColor];
}

- (void)setDetailtextLabelTextAndAdjustCellHeight:(NSString *)newText {
    if (self.descriptionWidth <= 0) {
        self.descriptionWidth = self.detailTextLabel.frame.size.width;
    }
    CGFloat oldHeight = self.detailTextLabel.frame.size.height;
    self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x,
                                            self.detailTextLabel.frame.origin.y,
                                            self.descriptionWidth,
                                            self.detailTextLabel.frame.size.height);
    self.detailTextLabel.text = newText;
    self.detailTextLabel.numberOfLines = 0;
    [self.detailTextLabel sizeToFit];
    CGFloat newHeight = self.detailTextLabel.frame.size.height;
    CGFloat heightDifference = newHeight - oldHeight;
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            MAX(self.frame.size.height + heightDifference, 80));
}

- (void)setUpWithItemForHeight:(PFObject *)item_ {
    self.item = item_;
    NSDictionary *description = [self.item objectForKey:@"description"];
    [self setDetailtextLabelTextAndAdjustCellHeight:[description objectForKey:@"description"]];
}

- (void)setUpWithItem:(PFObject *)item_ {
    [self setUpViews];

    self.item = item_;
    PFUser *user = [PFUser currentUser];
    PFObject *vendor = [GameUtils.instance getVendor:((PFObject *)[self.item objectForKey:@"vendor"]).objectId];
    NSMutableDictionary *progressMap = [user objectForKey:@"progressMap"];
    
    int target = [[self.item objectForKey:@"target"] intValue];
    int progress = 0;
    if ([progressMap objectForKey:self.item.objectId] != nil) {
        progress = [[[progressMap objectForKey:self.item.objectId] objectForKey:@"Count"] intValue];
    }
    
    NSDictionary *description = [self.item objectForKey:@"description"];
    PFFile *itemImageFile = [self.item objectForKey:@"image"];
    if (itemImageFile != (id)[NSNull null] && ![self.imageFile.url isEqual:itemImageFile.url]) {
        self.imageFile = itemImageFile;
        self.imageView.image = nil;
        int indexInTable_ = self.indexInTable;
        [self.imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            if (indexInTable_ == self.indexInTable) {
                self.imageView.image = image;
            }
        }];
    }
    
    self.textLabel.text = [vendor objectForKey:@"name"];
    if ([LocationManager allowLocationService]) {
        self.distanceLabel.hidden = NO;
        
        double distance = [[PFGeoPoint geoPointWithLocation:[LocationManager sharedSingleton].currentLocation]
                           distanceInMilesTo:[self.item objectForKey:@"location"]];
        self.distanceLabel.text = [[[GameUtils instance].distanceFormatter
                                    stringFromNumber:[NSNumber numberWithDouble:distance]] stringByAppendingString:@" mi"];
    } else {
        self.distanceLabel.hidden = YES;
    }
    [self setDetailtextLabelTextAndAdjustCellHeight:[description objectForKey:@"description"]];

    self.progressParentView.hidden = NO;
    NSString *progressText = [NSString stringWithFormat:@"%d / %d", progress, target];
    [self.redeemButton setTitle:progressText forState:UIControlStateNormal];
    self.redeemButton.userInteractionEnabled = NO;
    
    if (progress < 0) {
        progress = 0;
    } else if (progress > target) {
        progress = target;
    }
    
    self.redeemButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.progressView.frame = CGRectMake(self.progressView.frame.origin.x,
                                         self.progressView.frame.origin.y,
                                         MIN(redeemButton.frame.size.width * (float)progress / (float)target, redeemButton.frame.size.width),
                                         self.progressView.frame.size.height);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        DetailViewController *detailViewController = [[[DetailViewController alloc] initWithReward:self.item] autorelease];
        [self.rewardsTableViewController.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.textLabel.alpha = 0.5;
        self.detailTextLabel.alpha = 0.5;
        self.arrow.alpha = 0.5;
    } else {
        self.textLabel.alpha = 1;
        self.detailTextLabel.alpha = 1;
        self.arrow.alpha = 1;
    }
}

- (void)dealloc {
    [textLabel release], textLabel = nil;
    [detailTextLabel release], detailTextLabel = nil;
    [distanceLabel release], distanceLabel = nil;
    [imageView release], imageView = nil;
    [redeemButton release], redeemButton = nil;
    [progressView release], progressView = nil;
    [progressParentView release], progressParentView = nil;
    [item release], item = nil;
    [imageFile release], imageFile = nil;
    [imageContainerView release], imageContainerView = nil;
    rewardsTableViewController = nil;
    [arrow release], arrow = nil;
    [super dealloc];
}

@end
