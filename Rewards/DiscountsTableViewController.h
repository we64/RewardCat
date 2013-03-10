//
//  DiscountsTableViewController.h
//  RewardCat
//
//  Created by Chang Liu on 2013-02-17.
//
//

#import <Parse/Parse.h>

typedef enum {
    DiscountTypeNormal,
    DiscountTypeAd
} DiscountType;

@interface DiscountsTableViewController : PFQueryTableViewController

@end
