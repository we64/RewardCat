//
//  HistoryTableViewCell.m
//  RewardCat
//
//  Created by Chang Liu on 2013-01-28.
//
//

#import "HistoryTableViewCell.h"
#import "GameUtils.h"

@implementation HistoryTableViewCell

@synthesize itemViews;
@synthesize plusMinusSignLabels;
@synthesize itemImageViews;
@synthesize itemAmountLabels;
@synthesize messageLabel;
@synthesize timeLabel;
@synthesize backgroundImageView;

- (void)dealloc {
    [itemViews release], itemViews = nil;
    [plusMinusSignLabels release], plusMinusSignLabels = nil;
    [itemImageViews release], itemImageViews = nil;
    [itemAmountLabels release], itemAmountLabels = nil;
    [messageLabel release], messageLabel = nil;
    [timeLabel release], timeLabel = nil;
    [backgroundImageView release], backgroundImageView = nil;
    [super dealloc];
}

- (void)setUpWithCoin:(int)coin stamp:(int)stamp message:(NSString *)message time:(NSTimeInterval)time {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    timeLabel.text = [GameUtils timeStringWithGmtTimeInt:time];
    messageLabel.text = message;
    
    UIView *stampView = nil;
    UILabel *stampPlusMinusSignLabel = nil;
    UIImageView *stampImageView = nil;
    UILabel *stampAmountLabel = nil;
    UIView *coinView = nil;
    UILabel *coinPlusMinusSignLabel = nil;
    UIImageView *coinImageView = nil;
    UILabel *coinAmountLabel = nil;
    
    if (stamp != 0 && coin != 0) {
        stampView = [self.itemViews objectAtIndex:0];
        stampPlusMinusSignLabel = [self.plusMinusSignLabels objectAtIndex:0];
        stampImageView = [self.itemImageViews objectAtIndex:0];
        stampAmountLabel = [self.itemAmountLabels objectAtIndex:0];
        coinView = [self.itemViews objectAtIndex:1];
        coinPlusMinusSignLabel = [self.plusMinusSignLabels objectAtIndex:1];
        coinImageView = [self.itemImageViews objectAtIndex:1];
        coinAmountLabel = [self.itemAmountLabels objectAtIndex:1];
    } else if (stamp != 0) {
        stampView = [self.itemViews objectAtIndex:0];
        stampPlusMinusSignLabel = [self.plusMinusSignLabels objectAtIndex:0];
        stampImageView = [self.itemImageViews objectAtIndex:0];
        stampAmountLabel = [self.itemAmountLabels objectAtIndex:0];
        ((UIView *)[self.itemViews objectAtIndex:1]).hidden = YES;
    } else if (coin != 0) {
        coinView = [self.itemViews objectAtIndex:0];
        coinPlusMinusSignLabel = [self.plusMinusSignLabels objectAtIndex:0];
        coinImageView = [self.itemImageViews objectAtIndex:0];
        coinAmountLabel = [self.itemAmountLabels objectAtIndex:0];
        ((UIView *)[self.itemViews objectAtIndex:1]).hidden = YES;
    }
    
    coinView.hidden = NO;
    stampView.hidden = NO;
    
    coinAmountLabel.text = [NSString stringWithFormat:@"%d", abs(coin)];
    stampAmountLabel.text = [NSString stringWithFormat:@"%d", abs(stamp)];
    
    coinAmountLabel.textColor = [UIColor whiteColor];
    stampAmountLabel.textColor = [UIColor redColor];
    
    coinAmountLabel.shadowOffset = CGSizeMake(0, -1);
    stampAmountLabel.shadowOffset = CGSizeMake(0, 1);
    
    coinPlusMinusSignLabel.text = coin < 0 ? @"-" : @"+";
    stampPlusMinusSignLabel.text = stamp < 0 ? @"-" : @"+";
    
    coinImageView.image = [UIImage imageNamed:@"coin.png"];
    stampImageView.image = [UIImage imageNamed:@"stamp.png"];
    
    if (coin < 0 || stamp < 0) {
        self.backgroundImageView.image = [UIImage imageNamed:@"history2.png"];
    } else {
        self.backgroundImageView.image = [UIImage imageNamed:@"history1.png"];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
