//
//  HistoryTableViewCell.h
//  RewardCat
//
//  Created by Chang Liu on 2013-01-28.
//
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *itemViews;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *plusMinusSignLabels;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *itemImageViews;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *itemAmountLabels;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

- (void)setUpWithCoin:(int)coin stamp:(int)stamp message:(NSString *)message time:(NSTimeInterval)time;

@end
