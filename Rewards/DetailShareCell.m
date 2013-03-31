//
//  DetailShareCell.m
//  RewardCat
//
//  Created by Chang Liu on 2013-03-10.
//
//

#import "DetailShareCell.h"

@implementation DetailShareCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)showShare:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendShareTextMessage" object:nil];
}

@end
