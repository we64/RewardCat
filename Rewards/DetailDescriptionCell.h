//
//  DetailDescriptionCell.h
//  RewardCat
//
//  Created by Chang Liu on 2012-12-02.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailDescriptionCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *detail;

- (void)setDetailLabelTextAndAdjustCellHeight:(NSString *)newText;

@end
