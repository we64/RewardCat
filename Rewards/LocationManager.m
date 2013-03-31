//
//  LocationManager.m
//  RewardCat
//
//  Created by Chang Liu on 2013-01-20.
//
//

#import "LocationManager.h"

@implementation LocationManager

@synthesize locationManager;
@synthesize locationTimer;
@synthesize currentLocation;

- (id)init {
    self = [super init];
    
    if(self) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self;
        self.locationManager.purpose = @"Find rewards near you by allowing RewardCat to access your location.";
    }

    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];

    return self;
}

+ (LocationManager *)sharedSingleton {
    static LocationManager *sharedSingleton;
    if(!sharedSingleton) {
        @synchronized(sharedSingleton) {
            sharedSingleton = [[LocationManager alloc] init];
        }
    }
    
    return sharedSingleton;
}

- (void)startUpdatingLocation {
    [self.locationManager startUpdatingLocation];
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(stopUpdatingLocation) userInfo:nil repeats:NO];
}

- (void)stopUpdatingLocation {
    NSLog(@"stopped listening to location updates");
    [self.locationManager stopUpdatingLocation];
    [self.locationTimer invalidate];
    CLLocation *newLocation = self.locationManager.location;
    CLLocationDistance distanceDifferenceInMeters = [self.currentLocation distanceFromLocation:newLocation];
    self.currentLocation = newLocation;
    
    // if the distance difference is greater than 100, update all the list, or else don't bother
    // this is for better user experience, refreshing all 3 lists can be costly
    if (distanceDifferenceInMeters > 100) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"currentLocationRefreshed" object:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized) {
        // TODO: maybe do some useful logging here later
    }
}

+ (BOOL)allowLocationService {
    if ([CLLocationManager locationServicesEnabled] &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        return YES;
    } else {
        return NO;
    }
}

- (void)dealloc {
    [locationTimer invalidate];
    [locationManager release], locationManager = nil;
    [locationTimer release], locationTimer = nil;
    [currentLocation release], currentLocation = nil;
    [super dealloc];
}

@end
