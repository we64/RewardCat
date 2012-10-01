//
//  RewardModel.m
//  Rewards
//
//  Created by Chang Liu on 2012-09-30.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardModel.h"

@implementation RewardModel

@synthesize rewardId;
@synthesize deleted;
@synthesize target;

@synthesize title;
@synthesize descripton;
@synthesize image;

@synthesize vendorName;
@synthesize vendorAddress;
@synthesize vendorPhone;
@synthesize vendorWebsite;
@synthesize vendorDescription;

- (void)dealloc {
    [title release], title = nil;
    [descripton release], title = nil;
    [image release], image = nil;
    
    [vendorAddress release], vendorAddress = nil;
    [vendorName release], vendorName = nil;
    [vendorPhone release], vendorPhone = nil;
    [vendorWebsite release], vendorWebsite = nil;
    [vendorDescription release], vendorDescription = nil;
    [super dealloc];
}

@end
