//
//  DooberView.m
//  RewardCat
//
//  Created by Chang Liu on 2013-01-26.
//
//

#import "DooberView.h"
#import "GameUtils.h"
#import "Logger.h"

@implementation DooberView

@synthesize coinView;
@synthesize stampView;
@synthesize coinLabel;
@synthesize stampLabel;
@synthesize stampVendorLabel;
@synthesize inviteFriendsButton;
@synthesize pointRewardDescriptionLabel;
@synthesize pointRewardVendorLabel;
@synthesize pointRewardImageView;
@synthesize animationContainerView;
@synthesize pointReward;
@synthesize instructionWebView;

- (void)dealloc {
    [animationContainerView release], animationContainerView = nil;
    [coinView release], coinView = nil;
    [stampView release], stampView = nil;
    [stampLabel release], stampLabel = nil;
    [coinLabel release], coinLabel = nil;
    [stampVendorLabel release], stampVendorLabel = nil;
    [inviteFriendsButton release], inviteFriendsButton = nil;
    [pointRewardDescriptionLabel release], pointRewardDescriptionLabel = nil;
    [pointRewardVendorLabel release], pointRewardVendorLabel = nil;
    [pointRewardImageView release], pointRewardImageView = nil;
    [pointReward release], pointReward = nil;
    [instructionWebView release], instructionWebView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)dismiss:(id)sender {
    [GameUtils hideDooberView];
    [Logger.instance logButtonClick:@"Scan Dialog Close" pageName:@"Scan Dialog"];
}

- (IBAction)inviteFriends:(id)sender {
    [GameUtils showFacebookDialog];
    [Logger.instance logButtonClick:@"Facebook Invite" pageName:@"Scan Dialog"];
}

- (void)showWithStamp:(int)stamp coin:(int)coin vendorName:(NSString *)vendorName inviteMessage:(NSString *)inviteMessage pointReward:(PFObject *)pointReward_ instructionMessage:(NSString *)instructionMessage {

    self.pointReward = pointReward_;
    self.stampView.hidden = stamp <= 0;
    self.stampLabel.text = [NSString stringWithFormat:@"%d", stamp];

    self.coinView.hidden = coin <= 0;
    self.coinLabel.text = [NSString stringWithFormat:@"%d", coin];
    
    self.stampVendorLabel.text = [NSString stringWithFormat:@"at %@", vendorName];
    self.stampVendorLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.stampVendorLabel.numberOfLines = 0;
    [self.stampVendorLabel sizeToFit];
    CGRect stampVendorLabelframe = self.stampVendorLabel.frame;
    stampVendorLabelframe.size.width = 220.0f;
    if (stampVendorLabelframe.size.height >= 45.0f) {
        stampVendorLabelframe.origin = CGPointMake(self.stampVendorLabel.frame.origin.x, -12.0f);
    } else if (stampVendorLabelframe.size.height >= 25.0f) {
        stampVendorLabelframe.origin = CGPointMake(self.stampVendorLabel.frame.origin.x, -3.0f);
    } else {
        stampVendorLabelframe.origin = CGPointMake(self.stampVendorLabel.frame.origin.x, 10.0f);
    }
    self.stampVendorLabel.frame = stampVendorLabelframe;

    [self.inviteFriendsButton setTitle:inviteMessage forState:UIControlStateNormal];
    self.inviteFriendsButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.inviteFriendsButton.titleLabel.numberOfLines = 0;
    [self.inviteFriendsButton.titleLabel sizeToFit];
    CGRect inviteFriendsLabelframe = self.inviteFriendsButton.titleLabel.frame;
    inviteFriendsLabelframe.size.width = 220.0f;
    self.inviteFriendsButton.titleLabel.frame = inviteFriendsLabelframe;
    
    self.pointRewardDescriptionLabel.text = [[self.pointReward objectForKey:@"description"] objectForKey:@"description"];
    self.pointRewardDescriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.pointRewardDescriptionLabel.numberOfLines = 0;
    [self.pointRewardDescriptionLabel sizeToFit];
    CGRect pointRewardDescriptionLabelframe = self.pointRewardDescriptionLabel.frame;
    pointRewardDescriptionLabelframe.size.width = 155.0f;
    self.pointRewardDescriptionLabel.frame = pointRewardDescriptionLabelframe;
    
    PFObject *pointRewardVendor = [self.pointReward objectForKey:@"vendor"];
    self.pointRewardVendorLabel.text = [[[GameUtils instance].vendorDictionary objectForKey:pointRewardVendor.objectId] objectForKey:@"name"];
    self.pointRewardVendorLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.pointRewardVendorLabel.numberOfLines = 0;
    [self.pointRewardVendorLabel sizeToFit];
    CGRect pointRewardVendorLabelframe = self.pointRewardVendorLabel.frame;
    pointRewardVendorLabelframe.size.width = 155.0f;
    self.pointRewardVendorLabel.frame = pointRewardVendorLabelframe;
    
    PFFile *pointRewardImageFile = [self.pointReward objectForKey:@"image"];
    if (pointRewardImageFile != (id)[NSNull null]) {
        self.pointRewardImageView.image = nil;
        [pointRewardImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            self.pointRewardImageView.image = image;
        }];
    }
    
    [self.instructionWebView loadHTMLString:instructionMessage baseURL:nil];
    self.hidden = NO;
}

- (IBAction)showPointReward:(id)sender {
    [Logger.instance logButtonClick:@"PointReward Detail" pageName:@"Scan Dialog"];
    [GameUtils instance].nextGoToPointsRewardId = [self.pointReward objectForKey:@"objectId"];
    [GameUtils instance].tabBarController.selectedIndex = 2;
}

@end
