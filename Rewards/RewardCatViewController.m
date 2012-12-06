//
//  RewardCatViewController.m
//  RewardCat
//
//  Created by Chang Liu on 2012-11-18.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardCatViewController.h"

@interface RewardCatViewController ()

@end

@implementation RewardCatViewController

@synthesize selectedImage;
@synthesize unselectedImage;

- (void)dealloc {
    [selectedImage release], selectedImage = nil;
    [unselectedImage release], unselectedImage = nil;
    [super dealloc];
}

@end
