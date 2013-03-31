//
//  CategoryTableViewCell.h
//  RewardCat
//
//  Created by Chang Liu on 2013-03-23.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CategoryTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *categoryNameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *selectedImageView;
@property (nonatomic, retain) PFObject *categoryObject;

@end
