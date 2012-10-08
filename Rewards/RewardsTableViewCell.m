//
//  RewardsTableViewCell.m
//  Rewards
//
//  Created by Chang Liu on 2012-10-07.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardsTableViewCell.h"

@implementation RewardsTableViewCell

@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize imageView;
@synthesize indexInTable;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    NSArray *subViewArray = [[NSBundle mainBundle] loadNibNamed:@"RewardsTableViewCell" owner:self options:nil];
    UIView *mainView = [subViewArray objectAtIndex:0];
    [self addSubview:mainView];
    self.frame = mainView.frame;
    return self;
}

- (void)dealloc {
    [textLabel release], textLabel = nil;
    [detailTextLabel release], detailTextLabel = nil;
    [imageView release], imageView = nil;
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
