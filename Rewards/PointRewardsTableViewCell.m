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

@implementation PointRewardsTableViewCell

@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize pointsLabel;
@synthesize imageView;
@synthesize starView;
@synthesize redeemButton;
@synthesize detailsButton;
@synthesize indexInTable;
@synthesize item;
@synthesize pointRewardsTableViewController;
@synthesize imageFile;
@synthesize imageContainerView;

- (void)setUpViews {
    self.imageView.clipsToBounds = YES;
    self.imageContainerView.clipsToBounds = NO;
    self.imageContainerView.backgroundColor = [UIColor clearColor];
}

- (void)setUpWithItemForHeight:(PFObject *)item_ {
    self.item = item_;
    NSDictionary *description = [self.item objectForKey:@"description"];
    [self setDetailtextLabelTextAndAdjustCellHeight:[description objectForKey:@"description"]];
}

- (void)setDetailtextLabelTextAndAdjustCellHeight:(NSString *)newText {
    CGFloat oldHeight = self.detailTextLabel.frame.size.height;
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

- (void)setUpWithItem:(PFObject *)item_ {
    [self setUpViews];
    
    self.item = item_;
    PFUser *user = [PFUser currentUser];
    
    NSDictionary *description = [self.item objectForKey:@"description"];
    PFFile *itemImageFile = [self.item objectForKey:@"image"];
    if (itemImageFile != (id)[NSNull null] && ![self.imageFile.url isEqual:itemImageFile.url]) {
        self.imageFile = itemImageFile;
        self.imageView.image = nil;
        if (self.imageFile.isDataAvailable) {
            UIImage *image = [UIImage imageWithData:[imageFile getData]];
            self.imageView.image = image;
        } else {
            int indexInTable_ = self.indexInTable;
            [self.imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *errer) {
                UIImage *image = [UIImage imageWithData:[imageFile getData]];
                if (indexInTable_ == self.indexInTable) {
                    self.imageView.image = image;
                }
            }];
        }
    }
    self.textLabel.text = [description objectForKey:@"title"];

    [self setDetailtextLabelTextAndAdjustCellHeight:[description objectForKey:@"description"]];
    
    [self.redeemButton setBackgroundImage:[UIImage imageNamed:@"redeemgray"] forState:UIControlStateDisabled];
    [self.redeemButton setBackgroundImage:[UIImage imageNamed:@"redeem"] forState:UIControlStateNormal];
    if ([[self.item objectForKey:@"target"] intValue] > [[user objectForKey:@"rewardcatPoints"] intValue]) {
        [starView setImage:[UIImage imageNamed:@"stargray.png"]];
        self.redeemButton.enabled = NO;
    } else {
        [starView setImage:[UIImage imageNamed:@"star.png"]];
        self.redeemButton.enabled = YES;
    }
    
    self.pointsLabel.text = [[self.item objectForKey:@"target"] stringValue];
    if ([self.pointsLabel respondsToSelector:@selector(adjustsLetterSpacingToFitWidth)]) {
        self.pointsLabel.adjustsLetterSpacingToFitWidth = YES;
        self.pointsLabel.adjustsFontSizeToFitWidth = YES;
    } else {
        self.pointsLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)dealloc {
    [textLabel release], textLabel = nil;
    [detailTextLabel release], detailTextLabel = nil;
    [pointsLabel release], pointsLabel = nil;
    [imageView release], imageView = nil;
    [starView release], starView = nil;
    [redeemButton release], redeemButton = nil;
    [detailsButton release], detailsButton = nil;
    [item release], item = nil;
    [imageFile release], imageFile = nil;
    [imageContainerView release], imageContainerView = nil;
    [super dealloc];
}

- (IBAction)detailsButtonClicked:(id)sender {
    DetailViewController *detailViewController = [[[DetailViewController alloc] initWithReward:self.item redeem:FALSE] autorelease];
    [self.pointRewardsTableViewController.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction)redeemButtonClicked:(id)sender {
    NSTimeInterval redeemTimeLength = [[self.item objectForKey:@"redeemTimeLength"] doubleValue];
    [GameUtils showRedeemConfirmationWithTime:redeemTimeLength delegate:self];
}
                          
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"] && self.pointRewardsTableViewController.navigationController.topViewController.class != [DetailViewController class]) {
        DetailViewController *detailViewController = [[[DetailViewController alloc] initWithReward:self.item redeem:YES] autorelease];
        [self.pointRewardsTableViewController.navigationController pushViewController:detailViewController animated:YES];
    }
}

@end