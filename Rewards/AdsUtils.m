//
//  AdsUtils.m
//  RewardCat
//
//  Created by Chang Liu on 2013-02-24.
//
//

#import "AdsUtils.h"
#import "GameUtils.h"

static AdsUtils *adsUtilsInstance;

@interface AdsUtils ()

@property (nonatomic) int displayIndex;
@property (nonatomic) BOOL cycleStarted;

- (PFQuery *)getQuery;

@end

@implementation AdsUtils

NSString * const ParseObjectClassName = @"Discount";
@synthesize allAds;
@synthesize displayIndex;
@synthesize cycleStarted;

+ (AdsUtils *)instance {
    if (!adsUtilsInstance) {
        adsUtilsInstance = [[AdsUtils alloc] init];
        
        adsUtilsInstance.displayIndex = 0;
        adsUtilsInstance.allAds = [[[NSMutableArray alloc] init] autorelease];
    }
    return adsUtilsInstance;
}

- (PFQuery *)getQuery {
    PFQuery *query = [PFQuery queryWithClassName:ParseObjectClassName];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query setLimit:1000];
    [query whereKey:@"expireDate" greaterThanOrEqualTo:[GameUtils getToday]];
    [query whereKey:@"discountType" equalTo:[NSNumber numberWithInt:1]];
    [query orderByAscending:@"adRank"];

    return query;
}

- (void)startNextCycle {
    self.cycleStarted = YES;
    PFObject *currentAd = [self getAd];
    NSTimeInterval duration = MAX([[currentAd objectForKey:@"adDuration"] doubleValue], 1);
    [self performSelector:@selector(updateAd) withObject:nil afterDelay:duration];
}

- (void)updateAd {
    if (self.allAds.count <= 0) {
        return;
    }
    self.displayIndex = (self.displayIndex + 1) % self.allAds.count;
    [self startNextCycle];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"adsUpdated" object:nil];
}

- (PFObject *)getAd {
    if (self.allAds.count <= self.displayIndex) {
        return nil;
    }
    return (PFObject *)[self.allAds objectAtIndex:self.displayIndex];
}

- (void)refreshAdsList {
    PFQuery *query = [self getQuery];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded. Add the returned objects to allAds
            [self.allAds removeAllObjects];
            [self.allAds addObjectsFromArray:objects];
            if (!self.cycleStarted) {
                [self startNextCycle];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)dealloc {
    [allAds release], allAds = nil;
    [super dealloc];
}

@end
