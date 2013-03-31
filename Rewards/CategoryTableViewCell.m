//
//  CategoryTableViewCell.m
//  RewardCat
//
//  Created by Chang Liu on 2013-03-23.
//
//

#import "CategoryTableViewCell.h"
#import "GameUtils.h"

@implementation CategoryTableViewCell

@synthesize categoryNameLabel;
@synthesize selectedImageView;
@synthesize categoryObject;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return self;
    }

    self.selectionStyle = UITableViewCellSelectionStyleGray;

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        [GameUtils instance].currentCategory = categoryObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissCategoryView" object:nil];
    }
}

- (void)dealloc {
    [categoryNameLabel release], categoryNameLabel = nil;
    [selectedImageView release], selectedImageView = nil;
    [categoryObject release], categoryObject = nil;
    [super dealloc];
}

@end
