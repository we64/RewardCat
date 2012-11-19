//
//  PointRewardsTableViewCell.m
//  Rewards
//
//  Created by Chang Liu on 2012-11-11.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "PointRewardsTableViewCell.h"
#import "DetailViewController.h"

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

- (void)setUpWithItem:(PFObject *)item_ {
    [self setUpViews];
    
    self.item = item_;
    PFUser *user = [PFUser currentUser];
    
    NSDictionary *description = [self.item objectForKey:@"description"];
    if (![self.imageFile.url isEqual:((PFFile *)[self.item objectForKey:@"image"]).url]) {
        self.imageFile = [self.item objectForKey:@"image"];
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
    self.detailTextLabel.text = [description objectForKey:@"description"];
    self.detailTextLabel.numberOfLines = 0;
    [self.detailTextLabel sizeToFit];
    
    [self.redeemButton setBackgroundImage:[UIImage imageNamed:@"redeemgray"] forState:UIControlStateDisabled];
    [self.redeemButton setBackgroundImage:[UIImage imageNamed:@"redeem"] forState:UIControlStateNormal];
    if ([[self.item objectForKey:@"target"] intValue] > [[user objectForKey:@"RewardCatPoints"] intValue]) {
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
    [pointRewardsTableViewController release], pointRewardsTableViewController = nil;
    [imageFile release], imageFile = nil;
    [imageContainerView release], imageContainerView = nil;
    [super dealloc];
}

- (IBAction)detailsButtonClicked:(id)sender {
    DetailViewController *detailViewController = [[[DetailViewController alloc] initWithReward:self.item redeem:FALSE] autorelease];
    [[pointRewardsTableViewController navigationController] pushViewController:detailViewController animated:YES];
}

- (IBAction)redeemButtonClicked:(id)sender {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Are you sure you want to redeem this reward?"
                                                     message:@"Press OK to start the reward redemption process!"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK", nil] autorelease];
    [alert show];
}
                          
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"]) {
        DetailViewController *detailViewController = [[[DetailViewController alloc] initWithReward:self.item redeem:YES] autorelease];
        [[pointRewardsTableViewController navigationController] pushViewController:detailViewController animated:YES];
    }
}

@end