//
//  RewardsTableViewCell.h
//  Rewards
//
//  Created by Chang Liu on 2012-10-07.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RewardsTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *detailTextLabel;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic) int indexInTable;

@end
