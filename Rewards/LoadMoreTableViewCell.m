//
//  LoadMoreTableViewCell.m
//  RewardCat
//
//  Created by Chang Liu on 2012-11-18.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "LoadMoreTableViewCell.h"

@implementation LoadMoreTableViewCell

@synthesize backgroundView;
@synthesize loadMoreLabel;

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.backgroundView.alpha = 0.5;
    } else {
        self.backgroundView.alpha = 1;
    }
}

- (void)dealloc {
    [backgroundView release], backgroundView = nil;
    [loadMoreLabel release], loadMoreLabel = nil;
    [super dealloc];
}

@end
