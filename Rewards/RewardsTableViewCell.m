//
//  RewardsTableViewCell.m
//  Rewards
//
//  Created by Chang Liu on 2012-10-07.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardsTableViewCell.h"
#import "DetailViewController.h"

@implementation RewardsTableViewCell

@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize imageView;
@synthesize redeemButton;
@synthesize detailsButton;
@synthesize progressView;
@synthesize progressParentView;
@synthesize item;
@synthesize rewardsTableViewController;
@synthesize imageFile;
@synthesize indexInTable;
@synthesize imageContainerView;

- (void)setUpViews {
    self.imageView.clipsToBounds = YES;
    /*
    self.imageView.layer.cornerRadius = 5;
    self.imageContainerView.layer.cornerRadius = 5;
    self.imageContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageContainerView.layer.shadowOffset = CGSizeMake(0, 0.5);
    self.imageContainerView.layer.shadowOpacity = 1;
    self.imageContainerView.layer.shadowRadius = 0.5;
    */
    self.imageContainerView.clipsToBounds = NO;
    self.imageContainerView.backgroundColor = [UIColor clearColor];
}

- (void)setUpWithItem:(PFObject *)item_ {
    [self setUpViews];
    
    self.item = item_;
    PFUser *user = [PFUser currentUser];
    NSMutableDictionary *progressMap = [user objectForKey:@"progressMap"];
    
    int target = MAX(1,[[self.item objectForKey:@"target"] intValue]);
    int progress = 0;
    if ([progressMap objectForKey:self.item.objectId] != nil) {
        progress = MIN([[[progressMap objectForKey:self.item.objectId] objectForKey:@"Count"] intValue], target);
    }
    
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

    if (progress < target) {
        NSString *progressText = [[[[NSNumber numberWithInt:progress] stringValue]
                                   stringByAppendingString:@" / "] stringByAppendingString:[[NSNumber numberWithInt:target] stringValue]];
        [self.redeemButton setTitle:progressText forState:UIControlStateNormal];
        self.redeemButton.userInteractionEnabled = NO;
    } else {
        [self.redeemButton setTitle:@"Redeem Now!" forState:UIControlStateNormal];
        self.redeemButton.userInteractionEnabled = YES;
        [self.redeemButton setBackgroundImage:[UIImage imageNamed:@"barclicked"] forState:UIControlStateHighlighted];
    }
    self.redeemButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.progressView.frame = CGRectMake(self.progressView.frame.origin.x,
                                         self.progressView.frame.origin.y,
                                         MIN(redeemButton.frame.size.width * (float)progress / (float)target, redeemButton.frame.size.width),
                                         self.progressView.frame.size.height);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)dealloc {
    [textLabel release], textLabel = nil;
    [detailTextLabel release], detailTextLabel = nil;
    [imageView release], imageView = nil;
    [redeemButton release], redeemButton = nil;
    [detailsButton release], detailsButton = nil;
    [progressView release], progressView = nil;
    [progressParentView release], progressParentView = nil;
    [item release], item = nil;
    [rewardsTableViewController release], rewardsTableViewController = nil;
    [imageFile release], imageFile = nil;
    [imageContainerView release], imageContainerView = nil;
    [super dealloc];
}

- (IBAction)detailsButtonClicked:(id)sender {
    DetailViewController *detailViewController = [[[DetailViewController alloc] initWithReward:self.item redeem:FALSE] autorelease];
    [[rewardsTableViewController navigationController] pushViewController:detailViewController animated:YES];
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
        [[rewardsTableViewController navigationController] pushViewController:detailViewController animated:YES];
    }
}

@end
