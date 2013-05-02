//
//  AccountTableViewCell.m
//  RewardCat
//
//  Created by Chang Liu on 2013-02-18.
//
//

#import "AccountTableViewCell.h"
#import "GameUtils.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Logger.h"

@interface AccountTableViewCell ()

@end

@implementation AccountTableViewCell

@synthesize backgroundBottom;
@synthesize backgroundMiddle;
@synthesize backgroundTop;
@synthesize titleLabel;
@synthesize selected;
@synthesize loggedInAccountViewController;
@synthesize type;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (IBAction)clicked:(id)sender {
    self.backgroundTop.alpha = 0.5;
    self.backgroundBottom.alpha = 0.5;
    self.backgroundMiddle.alpha = 0.5;
}

- (IBAction)unclicked:(id)sender {
    self.backgroundTop.alpha = 1;
    self.backgroundBottom.alpha = 1;
    self.backgroundMiddle.alpha = 1;
}

- (IBAction)performAction:(id)sender {
    switch (self.type) {
        case FacebookLike:
            [self.loggedInAccountViewController likeButtonClicked];
            [Logger.instance logButtonClick:@"Like on Facebook" pageName:@"Account"];
            break;
        case Support:
            [self.loggedInAccountViewController supportButtonClicked];
            [Logger.instance logButtonClick:@"Contact Support" pageName:@"Account"];
            break;
        case Rate:
            [self.loggedInAccountViewController rateButtonClicked];
            [Logger.instance logButtonClick:@"Rate On App Store" pageName:@"Account"];
            break;
        case History:
            [self.loggedInAccountViewController historyButtonClicked];
            [Logger.instance logButtonClick:@"History" pageName:@"Account"];
            break;
        case Help:
            [GameUtils showTutorialWithFacebook:NO];
            [Logger.instance logButtonClick:@"Help" pageName:@"Account"];
            break;
        case Invite:
            [GameUtils showFacebookDialog];
            [Logger.instance logButtonClick:@"Facebook Invite" pageName:@"Account"];
            break;
        default:
            self.titleLabel.text = @"";
            break;
    }
}

- (void)setUpWithType:(AccountTableCellType)type_ position:(AccountTableCellPosition)position parent:(LoggedInAccountViewController *)parent {
    if (position == TableTop) {
        self.backgroundTop.image = [UIImage imageNamed:@"tabletop"];
        self.backgroundBottom.image = [UIImage imageNamed:@"rowbottom"];
    } else if (position == TableMiddle) {
        self.backgroundTop.image = [UIImage imageNamed:@"rowtop"];
        self.backgroundBottom.image = [UIImage imageNamed:@"rowbottom"];
    } else {
        self.backgroundTop.image = [UIImage imageNamed:@"rowtop"];
        self.backgroundBottom.image = [UIImage imageNamed:@"tablebottom"];
    }
    self.type = type_;
    self.loggedInAccountViewController = parent;
    switch (self.type) {
        case FacebookLike:
            self.titleLabel.text = @"Like Us on Facebook";
            break;
        case Support:
            self.titleLabel.text = @"Contact Support";
            break;
        case Rate:
            self.titleLabel.text = @"Rate Us on App Store";
            break;
        case History:
            self.titleLabel.text = @"View Transaction History";
            break;
        case Help:
            self.titleLabel.text = @"New User Help";
            break;
        case Invite:
            self.titleLabel.text = @"Invite Friends for Free Coins";
            break;
        default:
            self.titleLabel.text = @"";
            break;
    }
}

- (void)dealloc {
    [backgroundTop release], backgroundTop = nil;
    [backgroundBottom release], backgroundBottom = nil;
    [backgroundMiddle release], backgroundMiddle = nil;
    [titleLabel release], titleLabel = nil;
    [super dealloc];
}

@end
