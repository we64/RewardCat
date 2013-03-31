//
//  DetailFacebookCell.h
//  RewardCat
//
//  Created by Chang Liu on 2013-03-09.
//
//

#import <UIKit/UIKit.h>

@interface DetailFacebookCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *facebookButton;

- (void)setMessageDetailText:(NSString *)newText;
- (IBAction)showFacebookInvite:(id)sender;

@end
