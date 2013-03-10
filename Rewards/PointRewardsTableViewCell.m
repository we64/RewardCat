//
//  PointRewardsTableViewCell.m
//  Rewards
//
//  Created by Chang Liu on 2012-11-11.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "PointRewardsTableViewCell.h"
#import "DetailViewController.h"
#import "GameUtils.h"
#import "LocationManager.h"

@interface PointRewardsTableViewCell ()

@property (nonatomic) CGFloat descriptionWidth;

@end

@implementation PointRewardsTableViewCell

@synthesize textLabels;
@synthesize detailTextLabels;
@synthesize pointsLabels;
@synthesize distanceLabels;
@synthesize imageViews;
@synthesize starViews;
@synthesize detailsButtons;
@synthesize indicesInTable;
@synthesize items;
@synthesize pointRewardsTableViewController;
@synthesize imageFiles;
@synthesize imageContainerViews;

- (void)setUpViews {
    for (UIImageView *imageView_ in self.imageViews) {
        imageView_.clipsToBounds = YES;
    }
    for (UIImageView *imageContainerView in self.imageContainerViews) {
        imageContainerView.clipsToBounds = NO;
        imageContainerView.backgroundColor = [UIColor clearColor];
    }
}

- (void)setUpWithItems:(NSArray *)items_ {
    [self setUpViews];
    
    self.items = items_;
    PFUser *user = [PFUser currentUser];
    
    for (int i = 0; i < self.items.count; i++) {
        PFObject *item = [self.items objectAtIndex:i];
        NSDictionary *description = [item objectForKey:@"description"];
        PFFile *itemImageFile = [item objectForKey:@"image"];
        PFFile *imageFile = [self.imageFiles objectAtIndex:i];
        PFObject *vendor = [GameUtils.instance getVendor:((PFObject *)[item objectForKey:@"vendor"]).objectId];

        UIImageView *imageContainerView = [self.imageContainerViews objectAtIndex:i];
        UIImageView *imageView_ = [self.imageViews objectAtIndex:i];
        UILabel *textLabel_ = [self.textLabels objectAtIndex:i];
        UILabel *detailTextLabel_ = [self.detailTextLabels objectAtIndex:i];
        UIImageView *starView = [self.starViews objectAtIndex:i];
        UILabel *pointsLabel = [self.pointsLabels objectAtIndex:i];
        UILabel *distanceLabel = [self.distanceLabels objectAtIndex:i];
        
        if (!self.descriptionWidth) {
            self.descriptionWidth = detailTextLabel_.frame.size.width;
        }
        
        imageContainerView.hidden = NO;
        textLabel_.hidden = NO;
        starView.hidden = NO;
        pointsLabel.hidden = NO;
        distanceLabel.hidden = NO;
        detailTextLabel_.hidden = NO;
        
        if ([LocationManager allowLocationService]) {
            distanceLabel.hidden = NO;
            double distance = [[PFGeoPoint geoPointWithLocation:[LocationManager sharedSingleton].currentLocation]
                               distanceInMilesTo:[item objectForKey:@"location"]];
            distanceLabel.text = [[[GameUtils instance].distanceFormatter
                                        stringFromNumber:[NSNumber numberWithDouble:distance]] stringByAppendingString:@" mi"];
        } else {
            distanceLabel.hidden = YES;
        }

        imageView_.hidden = YES;
        if (itemImageFile != (id)[NSNull null] && ![imageFile.url isEqual:itemImageFile.url]) {
            imageFile = itemImageFile;
            imageView_.image = nil;
            int indexInTable_ = [[self.indicesInTable objectAtIndex:i] intValue];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                int indexInTable = [[self.indicesInTable objectAtIndex:i] intValue];
                UIImage *image = [UIImage imageWithData:data];
                if (indexInTable_ == indexInTable) {
                    imageView_.image = image;
                    imageView_.hidden = NO;
                }

            }];
        }

        textLabel_.text = [vendor objectForKey:@"name"];
        CGFloat oldBottomLine = detailTextLabel_.frame.origin.y + detailTextLabel_.frame.size.height;
        detailTextLabel_.text = [description objectForKey:@"description"];
        detailTextLabel_.numberOfLines = 0;
        [detailTextLabel_ sizeToFit];
        CGFloat newOriginY = oldBottomLine - detailTextLabel_.frame.size.height;
        
        detailTextLabel_.frame = CGRectMake(detailTextLabel_.frame.origin.x,
                                            newOriginY,
                                            self.descriptionWidth,
                                            detailTextLabel_.frame.size.height);
        
        if ([[item objectForKey:@"target"] intValue] > [[user objectForKey:@"rewardcatPoints"] intValue]) {
            [starView setImage:[UIImage imageNamed:@"coingrey.png"]];
        } else {
            [starView setImage:[UIImage imageNamed:@"coin.png"]];
        }
        
        pointsLabel.text = [[item objectForKey:@"target"] stringValue];
        if ([pointsLabel respondsToSelector:@selector(adjustsLetterSpacingToFitWidth)]) {
            pointsLabel.adjustsLetterSpacingToFitWidth = YES;
            pointsLabel.adjustsFontSizeToFitWidth = YES;
        } else {
            pointsLabel.adjustsFontSizeToFitWidth = YES;
        }
    }
    
    for (int i = self.items.count; i < self.detailsButtons.count; i++) {
        UIImageView *imageContainerView = [self.imageContainerViews objectAtIndex:i];
        UILabel *textLabel_ = [self.textLabels objectAtIndex:i];
        UILabel *detailTextLabel_ = [self.detailTextLabels objectAtIndex:i];
        UIImageView *starView = [self.starViews objectAtIndex:i];
        UILabel *pointsLabel = [self.pointsLabels objectAtIndex:i];
        UILabel *distanceLabel = [self.distanceLabels objectAtIndex:i];
        
        imageContainerView.hidden = YES;
        detailTextLabel_.hidden = YES;
        textLabel_.hidden = YES;
        starView.hidden = YES;
        pointsLabel.hidden = YES;
        distanceLabel.hidden = YES;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (IBAction)detailsButtonClicked:(id)sender {
    int i = [self.detailsButtons indexOfObject:sender];
    if (i > self.items.count - 1) {
        return;
    }
    PFObject *item = [self.items objectAtIndex:i];
    DetailViewController *detailViewController = [[[DetailViewController alloc] initWithReward:item] autorelease];
    [self.pointRewardsTableViewController.navigationController pushViewController:detailViewController animated:YES];
}

- (void)dealloc {
    [textLabels release], textLabels = nil;
    [detailTextLabels release], detailTextLabels = nil;
    [distanceLabels release], distanceLabels = nil;
    [pointsLabels release], pointsLabels = nil;
    [imageViews release], imageViews = nil;
    [starViews release], starViews = nil;
    [items release], items = nil;
    [imageFiles release], imageFiles = nil;
    [imageContainerViews release], imageContainerViews = nil;
    [detailsButtons release], detailsButtons = nil;
    [super dealloc];
}

@end