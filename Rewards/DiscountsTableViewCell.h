//
//  DiscountsTableViewCell.h
//  RewardCat
//
//  Created by Chang Liu on 2013-02-17.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "DiscountsTableViewController.h"

@interface DiscountsTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *detailTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIView *imageContainerView;
@property (nonatomic, retain) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, retain) IBOutlet UILabel *discountTagLabel;
@property (nonatomic, retain) IBOutlet UIImageView *discountTagImageView;

@property (nonatomic, retain) PFObject *item;
@property (nonatomic, assign) DiscountsTableViewController *discountsTableViewController;
@property (nonatomic, retain) PFFile *imageFile;

@property (nonatomic, retain) NSIndexPath *indexInTable;

@property (nonatomic) CGFloat descriptionWidth;

- (void)setUpWithItem:(PFObject *)item;
- (void)updateAdForHeight:(BOOL)checkingForHeight;
- (void)setUpWithItemForHeight:(PFObject *)item_;

@end
