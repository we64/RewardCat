//
//  AccountTableViewCell.h
//  RewardCat
//
//  Created by Chang Liu on 2013-02-18.
//
//

#import <UIKit/UIKit.h>
#import "LoggedInAccountViewController.h"

typedef enum {
    TableTop,
    TableMiddle,
    TableBottom
} AccountTableCellPosition;

typedef enum {
    Invite,
    FacebookLike,
    Rate,
    History,
    Help,
    Support,
    AccountTableCellTypeCount
} AccountTableCellType;

@interface AccountTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *backgroundTop;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundMiddle;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundBottom;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) LoggedInAccountViewController *loggedInAccountViewController;
@property (nonatomic) AccountTableCellType type;

- (void)setUpWithType:(AccountTableCellType)type_ position:(AccountTableCellPosition)position parent:(LoggedInAccountViewController *)parent;
- (IBAction)performAction:(id)sender;
- (IBAction)unclicked:(id)sender;
- (IBAction)clicked:(id)sender;

@end
