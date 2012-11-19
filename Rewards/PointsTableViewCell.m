//
//  PointsTableViewCell.m
//  RewardCat
//
//  Created by Chang Liu on 2012-11-18.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "PointsTableViewCell.h"
#import <Parse/Parse.h>

@implementation PointsTableViewCell

@synthesize pointsLabel;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)dealloc {
    [pointsLabel release], pointsLabel = nil;
    [super dealloc];
}

@end
