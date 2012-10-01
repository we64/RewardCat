//
//  UserModel.m
//  Rewards
//
//  Created by Chang Liu on 2012-09-30.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

@synthesize udid;
@synthesize progressMap;

- (void) dealloc {
    [udid release], udid = nil;
    [progressMap release], progressMap = nil;
    [super dealloc];
}

@end
