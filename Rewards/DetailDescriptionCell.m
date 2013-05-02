//
//  DetailDescriptionCell.m
//  RewardCat
//
//  Created by Chang Liu on 2012-12-02.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "DetailDescriptionCell.h"

@implementation DetailDescriptionCell

@synthesize detail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setDetailLabelTextAndAdjustCellHeight:(NSString *)newText {
    CGFloat oldHeight = self.detail.frame.size.height;
    self.detail.text = newText;
    self.detail.numberOfLines = 0;
    [self.detail sizeToFit];
    CGFloat newHeight = self.detail.frame.size.height;
    CGFloat heightDifference = newHeight - oldHeight;
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            MAX(self.frame.size.height + heightDifference, 0));
}

- (void)dealloc {
    [detail release], detail = nil;
    [super dealloc];
}

@end
