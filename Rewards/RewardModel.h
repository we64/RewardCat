//
//  RewardModel.h
//  Rewards
//
//  Created by Chang Liu on 2012-09-30.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface RewardModel : PFObject

@property (nonatomic) int rewardId;
@property (nonatomic) BOOL deleted;
@property (nonatomic) int target;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *descripton;
@property (nonatomic, retain) UIImage *image;

@property (nonatomic, retain) NSString *vendorName;
@property (nonatomic, retain) NSString *vendorAddress;
@property (nonatomic, retain) NSString *vendorPhone;
@property (nonatomic, retain) NSString *vendorWebsite;
@property (nonatomic, retain) NSString *vendorDescription;

@end
