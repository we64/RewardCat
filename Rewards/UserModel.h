//
//  UserModel.h
//  Rewards
//
//  Created by Chang Liu on 2012-09-30.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface UserModel : PFObject

@property (nonatomic, retain) NSString *udid;
@property (nonatomic, retain) NSMutableDictionary *progressMap;

@end
