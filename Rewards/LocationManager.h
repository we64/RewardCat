//
//  LocationManager.h
//  RewardCat
//
//  Created by Chang Liu on 2013-01-20.
//
//

#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSTimer *locationTimer;

+ (LocationManager *)sharedSingleton;
+ (BOOL)allowLocationService;

- (void)startUpdatingLocation;

@end