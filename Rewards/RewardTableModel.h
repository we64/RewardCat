//
//  RewardTableModel.h
//  Rewards
//
//  Created by Chang Liu on 2012-09-30.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface RewardTableModel : PFObject

@property (nonatomic, retain) NSArray *rewards;

@end
