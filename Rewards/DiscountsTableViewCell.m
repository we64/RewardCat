//
//  DiscountsTableViewCell.m
//  RewardCat
//
//  Created by Chang Liu on 2013-02-17.
//
//

#import "DiscountsTableViewCell.h"
#import "DiscountsViewController.h"
#import "DiscountsTableViewController.h"
#import "DetailViewController.h"
#import "GameUtils.h"
#import "LocationManager.h"
#import "AdsUtils.h"

@implementation DiscountsTableViewCell

@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize distanceLabel;
@synthesize imageView;
@synthesize item;
@synthesize discountsTableViewController;
@synthesize imageFile;
@synthesize indexInTable;
@synthesize imageContainerView;
@synthesize arrowImageView;
@synthesize discountTagImageView;
@synthesize discountTagLabel;
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

- (void)updateAdForHeight:(BOOL)checkingForHeight {
    PFObject *adObject = [[AdsUtils instance] getAd];
    if (checkingForHeight) {
        [self setUpWithItemForHeight:adObject];
    } else {
        [self setUpWithItem:adObject];
    }
}

- (void)setUpWithItemForHeight:(PFObject *)item_ {
    self.item = item_;
    NSDictionary *description = [self.item objectForKey:@"description"];
    [self setDetailtextLabelTextAndAdjustCellHeight:[description objectForKey:@"description"]];
}

- (void)setUpWithItem:(PFObject *)item_ {
    [self setUpViews];
    
    self.item = item_;
    PFObject *vendor = [GameUtils.instance getVendor:((PFObject *)[self.item objectForKey:@"vendor"]).objectId];

    NSDictionary *description = [self.item objectForKey:@"description"];
    PFFile *itemImageFile = [self.item objectForKey:@"image"];
    if (itemImageFile != (id)[NSNull null] && ![self.imageFile.url isEqual:itemImageFile.url]) {
        self.imageFile = itemImageFile;
        self.imageView.image = nil;
        NSIndexPath *indexInTable_ = [NSIndexPath indexPathForRow:self.indexInTable.row inSection:self.indexInTable.section];
        [self.imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            if ([indexInTable_ isEqual:self.indexInTable]) {
                self.imageView.image = image;
            }
        }];
    }
    
    [self setDetailtextLabelTextAndAdjustCellHeight:[description objectForKey:@"description"]];
    
    self.discountTagLabel.text = [description objectForKey:@"discountTag"];
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
    self.discountTagImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@tag.png", [self.item objectForKey:@"tagColor"]]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        DetailViewController *detailViewController = [[[DetailViewController alloc] initWithReward:self.item] autorelease];
        [self.discountsTableViewController.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.textLabel.alpha = 0.5;
        self.detailTextLabel.alpha = 0.5;
        self.arrowImageView.alpha = 0.5;
    } else {
        self.textLabel.alpha = 1;
        self.detailTextLabel.alpha = 1;
        self.arrowImageView.alpha = 1;
    }
}

- (void)dealloc {
    [textLabel release], textLabel = nil;
    [detailTextLabel release], detailTextLabel = nil;
    [distanceLabel release], distanceLabel = nil;
    [imageView release], imageView = nil;
    [item release], item = nil;
    [imageFile release], imageFile = nil;
    [imageContainerView release], imageContainerView = nil;
    discountsTableViewController = nil;
    [arrowImageView release], arrowImageView = nil;
    [discountTagImageView release], discountTagImageView = nil;
    [discountTagLabel release], discountTagLabel = nil;
    [super dealloc];
}

@end
