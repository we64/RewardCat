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

    [self.locationManager setDistanceFilter:kCLLocationAccuracyHundredMeters];
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
    self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(stopUpdatingLocation) userInfo:nil repeats:NO];
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
    [self.locationTimer invalidate];
    self.currentLocation = self.locationManager.location;;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (newLocation.coordinate.latitude != oldLocation.coordinate.latitude ||
        newLocation.coordinate.longitude != oldLocation.coordinate.longitude) {
        [self stopUpdatingLocation];
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
