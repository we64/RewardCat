//
//  Logger.m
//  RewardCat
//
//  Created by Chang Liu on 2013-04-06.
//
//

#import "Logger.h"

static Logger *loggerInstance;

@interface Logger ()

@end

@implementation Logger

+ (Logger *)instance {
    if (!loggerInstance) {
        loggerInstance = [[Logger alloc] init];
    }
    return loggerInstance;
}

- (void)logPageImpression:(NSString *)pageName {
    PFObject *log = [PFObject objectWithClassName:@"Log"];
    [log setObject:[pageName stringByAppendingString:@" impression"] forKey:@"activityDescription"];
    [log setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"loggedTime"];
    [log setObject:[PFUser currentUser] forKey:@"user"];
    [log saveEventually];
}

- (void)logAdImpression:(PFObject *)ad {
    PFObject *log = [PFObject objectWithClassName:@"Log"];
    [log setObject:@"Ad shown" forKey:@"activityDescription"];
    [log setObject:ad forKey:@"discount"];
    [log setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"loggedTime"];
    [log setObject:[PFUser currentUser] forKey:@"user"];
    [log saveEventually];
}

- (void)logDetailImpression:(PFObject *)object redeemFlag:(BOOL)redeemFlag {
    PFObject *log = [PFObject objectWithClassName:@"Log"];
    if ([object.parseClassName isEqualToString:@"Reward"]) {
        [log setObject:object forKey:@"reward"];
    } else if ([object.parseClassName isEqualToString:@"PointReward"]) {
        [log setObject:object forKey:@"pointReward"];
    } else {
        [log setObject:object forKey:@"discount"];
    }
    [log setObject:@"Detail page impression" forKey:@"activityDescription"];
    [log setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"loggedTime"];
    [log setObject:[PFUser currentUser] forKey:@"user"];
    [log setObject:[NSNumber numberWithBool:redeemFlag] forKey:@"redeemFlag"];
    [log saveEventually];
}

- (void)logButtonClick:(NSString *)message pageName:(NSString *)pageName {
    PFObject *log = [PFObject objectWithClassName:@"Log"];
    [log setObject:[PFUser currentUser] forKey:@"user"];
    NSString *fullMessage = [[[[@"Clicked " stringByAppendingString:message] stringByAppendingString:@" button on "] stringByAppendingString:pageName] stringByAppendingString:@" tab"];
    [log setObject:fullMessage forKey:@"activityDescription"];
    [log setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"loggedTime"];
    [log saveEventually];
}

- (void)logButtonClick:(NSString *)message object:(PFObject *)object {
    PFObject *log = [PFObject objectWithClassName:@"Log"];
    if ([object.parseClassName isEqualToString:@"Reward"]) {
        [log setObject:object forKey:@"reward"];
    } else if ([object.parseClassName isEqualToString:@"PointReward"]) {
        [log setObject:object forKey:@"pointReward"];
    } else {
        [log setObject:object forKey:@"discount"];
    }
    NSString *fullMessage = [[[[@"Clicked " stringByAppendingString:message] stringByAppendingString:@" button on "] stringByAppendingString:object.parseClassName] stringByAppendingString:@" detail page"];
    [log setObject:fullMessage forKey:@"activityDescription"];
    [log setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"loggedTime"];
    [log setObject:[PFUser currentUser] forKey:@"user"];
    [log saveEventually];
}

- (void)logEvent:(NSString *)eventName {
    PFObject *log = [PFObject objectWithClassName:@"Log"];
    [log setObject:[PFUser currentUser] forKey:@"user"];
    [log setObject:eventName forKey:@"activityDescription"];
    [log setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"loggedTime"];
    [log saveEventually];
}

- (void)logErrorEvent:(NSString *)eventName error:(NSDictionary *)error {
    PFObject *log = [PFObject objectWithClassName:@"Log"];
    [log setObject:[PFUser currentUser] forKey:@"user"];
    [log setObject:eventName forKey:@"activityDescription"];
    [log setObject:error forKey:@"error"];
    [log setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"loggedTime"];
    [log saveEventually];
}

- (void)dealloc {
    [super dealloc];
}

@end
