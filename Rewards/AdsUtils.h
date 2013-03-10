//
//  AdsUtils.h
//  RewardCat
//
//  Created by Chang Liu on 2013-02-24.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface AdsUtils : NSObject

extern NSString * const ParseObjectClassName;

@property (nonatomic, retain) NSMutableArray *allAds;

- (PFObject *)getAd;
- (void)refreshAdsList;

+ (AdsUtils *)instance;

@end
