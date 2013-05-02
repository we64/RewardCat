//
//  DooberView.h
//  RewardCat
//
//  Created by Chang Liu on 2013-01-26.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DooberView : UIView

@property (nonatomic, retain) IBOutlet UIView *stampView;
@property (nonatomic, retain) IBOutlet UIView *coinView;
@property (nonatomic, retain) IBOutlet UILabel *stampLabel;
@property (nonatomic, retain) IBOutlet UILabel *coinLabel;
@property (nonatomic, retain) IBOutlet UILabel *stampVendorLabel;
@property (nonatomic, retain) IBOutlet UIButton *inviteFriendsButton;
@property (nonatomic, retain) IBOutlet UILabel *pointRewardDescriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *pointRewardVendorLabel;
@property (nonatomic, retain) IBOutlet UIImageView *pointRewardImageView;
@property (nonatomic, retain) IBOutlet UIView *animationContainerView;
@property (nonatomic, retain) PFObject *pointReward;
@property (nonatomic, retain) IBOutlet UIWebView *instructionWebView;

- (void)showWithStamp:(int)stamp coin:(int)coin vendorName:(NSString *)vendorName inviteMessage:(NSString *)inviteMessage pointReward:(PFObject *)pointReward instructionMessage:(NSString *)instructionMessage;
- (IBAction)inviteFriends:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)showPointReward:(id)sender;

@end
