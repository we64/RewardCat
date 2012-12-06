//
//  DetailInfoCell.m
//  RewardCat
//
//  Created by Chang Liu on 2012-12-01.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "DetailInfoCell.h"

@implementation DetailInfoCell

@synthesize title;
@synthesize info;
@synthesize bottomBorder;
@synthesize topBorder;
@synthesize middle;
@synthesize action;
@synthesize coordinates;
@synthesize businessName;
@synthesize icon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setInfoLabelTextAndAdjustCellHeight:(NSString *)newText {
    CGFloat oldHeight = self.info.frame.size.height;
    self.info.text = newText;
    self.info.numberOfLines = 0;
    [self.info sizeToFit];
    CGFloat newHeight = self.info.frame.size.height;
    CGFloat heightDifference = newHeight - oldHeight;
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            MAX(self.frame.size.height + heightDifference, 50));
}

- (IBAction)clicked:(id)sender {
    self.middle.alpha = 0.5;
    self.topBorder.alpha = 0.5;
    self.bottomBorder.alpha = 0.5;
}

- (IBAction)unclicked:(id)sender {
    self.middle.alpha = 1;
    self.topBorder.alpha = 1;
    self.bottomBorder.alpha = 1;
}

- (IBAction)performAction:(id)sender {
    BOOL isMapUrl = [[self.action absoluteString] rangeOfString:@"maps.google"].location != NSNotFound;
    NSArray *versionArray = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    BOOL isIOS6 = [[versionArray objectAtIndex:0] intValue] >= 6;
    if (isMapUrl && isIOS6 && self.coordinates && self.coordinates.count >= 2) {
        // Create an MKMapItem to pass to the Maps app
        double latitude = [[self.coordinates objectAtIndex:0] doubleValue];
        double longitude = [[self.coordinates objectAtIndex:1] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        MKPlacemark *placemark = [[[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil] autorelease];
        MKMapItem *mapItem = [[[MKMapItem alloc] initWithPlacemark:placemark] autorelease];
        [mapItem setName:businessName];
        // Pass the map item to the Maps app
        [mapItem openInMapsWithLaunchOptions:nil];
    } else {
        [[UIApplication sharedApplication] openURL:self.action];
    }
}

- (void)dealloc {
    [title release], title = nil;
    [info release], info = nil;
    [bottomBorder release], bottomBorder = nil;
    [topBorder release], topBorder = nil;
    [middle release], middle = nil;
    [action release], action = nil;
    [coordinates release], coordinates = nil;
    [businessName release], businessName = nil;
    [icon release], icon = nil;
    [super dealloc];
}

@end
