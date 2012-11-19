//
//  DetailViewController.h
//  Rewards
//
//  Created by Chang Liu on 2012-10-28.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DetailViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UITextView *descriptionText;
@property (nonatomic, retain) IBOutlet UIImageView *pictureView;
@property (nonatomic, retain) IBOutlet UILabel *countDownLabel;
@property (nonatomic, retain) IBOutlet UILabel *countDownDescriptionLabel;
@property (nonatomic, retain) IBOutlet UIView *detailsView;
@property (nonatomic, retain) IBOutlet UIView *pictureContainerView;
@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UIView *progressParentView;
@property (nonatomic, retain) IBOutlet UIView *countDownParentView;
@property (nonatomic, retain) IBOutlet UIButton *redeemButton;

@property (nonatomic, retain) NSTimer *countDownTimer;
@property (nonatomic) NSTimeInterval countDownStartTime;

@property (nonatomic, retain) PFObject *reward;

@property (nonatomic) BOOL redeem;

- (id)initWithReward:(PFObject *)reward_ redeem:(BOOL)redeem;

@end
