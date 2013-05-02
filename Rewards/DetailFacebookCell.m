//
//  DetailFacebookCell.m
//  RewardCat
//
//  Created by Chang Liu on 2013-03-09.
//
//

#import "DetailFacebookCell.h"
#import "GameUtils.h"

@implementation DetailFacebookCell

@synthesize facebookButton;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

- (void)setMessageDetailText:(NSString *)newText {
    [self.facebookButton setTitle:newText forState:UIControlStateNormal];
    self.facebookButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.facebookButton.titleLabel.numberOfLines = 0;
}

- (IBAction)showFacebookInvite:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookInviteOnDetailClicked" object:nil];
    [GameUtils showFacebookDialog];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [facebookButton release], facebookButton = nil;
    [super dealloc];
}

@end
