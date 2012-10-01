//
//  RewardTableModel.m
//  Rewards
//
//  Created by Chang Liu on 2012-09-30.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardTableModel.h"

@implementation RewardTableModel

@synthesize rewards;

- (id)init {
    self = [super init];
    if (!self) {
        return self;
    }
    
    return self;
}

- (void)dealloc {
    [rewards release], rewards = nil;
    [super dealloc];
}

@end
