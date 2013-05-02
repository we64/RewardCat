//
//  Logger.h
//  RewardCat
//
//  Created by Chang Liu on 2013-04-06.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Logger : NSObject

+ (Logger *)instance;

- (void)logPageImpression:(NSString *)pageName;
- (void)logAdImpression:(PFObject *)ad;
- (void)logDetailImpression:(PFObject *)object redeemFlag:(BOOL)redeemFlag;
- (void)logButtonClick:(NSString *)message pageName:(NSString *)pageName;
- (void)logButtonClick:(NSString *)message object:(PFObject *)object;
- (void)logEvent:(NSString *)eventName;
- (void)logErrorEvent:(NSString *)eventName error:(NSDictionary *)error;

@end
