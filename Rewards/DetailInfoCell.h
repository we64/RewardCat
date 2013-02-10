//
//  DetailInfoCell.h
//  RewardCat
//
//  Created by Chang Liu on 2012-12-01.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DetailInfoCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *info;
@property (nonatomic, retain) IBOutlet UIImageView *topBorder;
@property (nonatomic, retain) IBOutlet UIImageView *middle;
@property (nonatomic, retain) IBOutlet UIImageView *bottomBorder;
@property (nonatomic, retain) NSURL *action;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *businessName;
@property (nonatomic, retain) IBOutlet UIImageView *icon;

- (void)setInfoLabelTextAndAdjustCellHeight:(NSString *)newText;

@end
