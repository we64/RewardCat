//
//  DetailViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-10-28.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation DetailViewController

@synthesize descriptionText;
@synthesize pictureView;
@synthesize reward;
@synthesize redeem;
@synthesize countDownLabel;
@synthesize countDownStartTime;
@synthesize countDownTimer;
@synthesize countDownDescriptionLabel;
@synthesize detailsView;
@synthesize pictureContainerView;
@synthesize progressView;
@synthesize redeemButton;
@synthesize progressParentView;
@synthesize countDownParentView;

#define redeemTime 120

- (id)initWithReward:(PFObject *)reward_ redeem:(BOOL)redeem_ {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.reward = reward_;
    self.redeem = redeem_;
    return self;
}

- (void)setUpViews {
    /*
    self.descriptionText.backgroundColor = [UIColor clearColor];
    self.descriptionText.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.descriptionText.layer.shadowOffset = CGSizeMake(0, -1);
    self.descriptionText.layer.shadowOpacity = 1;
    self.descriptionText.layer.shadowRadius = 0;
    
    self.detailsView.layer.cornerRadius = 5;
    
    self.detailsView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.detailsView.layer.shadowOffset = CGSizeMake(0, 2);
    self.detailsView.layer.shadowOpacity = 1;
    self.detailsView.layer.shadowRadius = 3;
    
    self.pictureView.layer.cornerRadius = 5;
    self.pictureView.clipsToBounds = YES;
    
    self.pictureContainerView.layer.cornerRadius = 5;
    
    self.pictureContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.pictureContainerView.layer.shadowOffset = CGSizeMake(0, 2);
    self.pictureContainerView.layer.shadowOpacity = 1;
    self.pictureContainerView.layer.shadowRadius = 3;
    
    self.pictureContainerView.clipsToBounds = NO;
    self.pictureContainerView.backgroundColor = [UIColor clearColor];
     */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpViews];
    
    self.descriptionText.text = [NSString stringWithFormat:@"%@\n%@\n%@",
                                 [[reward objectForKey:@"description"] objectForKey:@"phone"],
                                 [[reward objectForKey:@"description"] objectForKey:@"address"],
                                 [[reward objectForKey:@"description"] objectForKey:@"longDescription"]];

    PFUser *user = [PFUser currentUser];
    NSMutableDictionary *progressMap = [user objectForKey:@"progressMap"];
    
    int target = MAX(1,[[reward objectForKey:@"target"] intValue]);
    int progress = 0;
    if ([[reward className] isEqualToString:@"Reward"]) {
        if ([progressMap objectForKey:reward.objectId] != nil) {
            progress = MIN([[[progressMap objectForKey:reward.objectId] objectForKey:@"Count"] intValue], target);
        }
    } else if ([[reward className] isEqualToString:@"PointReward"]) {
        progress = MIN([[user objectForKey:@"RewardCatPoints"] intValue], target);
    }
    
    PFFile *imageFile = [self.reward objectForKey:@"image"];
    self.pictureView.image = nil;
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *errer) {
        UIImage *image = [UIImage imageWithData:[imageFile getData]];
        self.pictureView.image = image;
    }];
    self.title = [[reward objectForKey:@"description"] objectForKey:@"title"];
    
    if (self.redeem) {
        [self redeemRewards];
    } else {
        self.countDownParentView.hidden = YES;

        if (progress < target) {
            NSString *progressText = [[[[NSNumber numberWithInt:progress] stringValue]
                                       stringByAppendingString:@" / "] stringByAppendingString:[[NSNumber numberWithInt:target] stringValue]];
            [self.redeemButton setTitle:progressText forState:UIControlStateNormal];
            self.redeemButton.userInteractionEnabled = NO;
        } else {
            [self.redeemButton setTitle:@"Redeem Now!" forState:UIControlStateNormal];
            self.redeemButton.userInteractionEnabled = YES;
            [self.redeemButton setBackgroundImage:[UIImage imageNamed:@"barbigclick"] forState:UIControlStateHighlighted];
        }
        self.redeemButton.titleLabel.textAlignment = UITextAlignmentCenter;
        self.progressView.frame = CGRectMake(self.progressView.frame.origin.x,
                                             self.progressView.frame.origin.y,
                                             MIN(redeemButton.frame.size.width * (float)progress / (float)target, redeemButton.frame.size.width),
                                             self.progressView.frame.size.height);
    }
}

- (void)updateCountDown {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now > self.countDownStartTime + redeemTime) {
        [self.countDownTimer invalidate];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSTimeInterval timeRemaining = self.countDownStartTime + redeemTime - now;
        int seconds = (int)floor(timeRemaining) % 60;
        int minutes = (int)floor(timeRemaining / 60);
        self.countDownLabel.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)redeemRewards {
    self.progressParentView.hidden = YES;
    self.countDownParentView.hidden = NO;
    self.countDownStartTime = [[NSDate date] timeIntervalSince1970];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateCountDown) userInfo:nil repeats:YES];
    
    NSArray *keys = [NSArray arrayWithObjects:@"rewardID", @"target", @"rewardType", nil];
    NSArray *objects = [NSArray arrayWithObjects:reward.objectId,
                        [reward objectForKey:@"target"],
                        [reward className],
                        nil];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects
                                                           forKeys:keys];
    [PFCloud callFunctionInBackground:@"redeemReward" withParameters:dictionary block:^(id result, NSError *error) {
        if (!error) {
            [[PFUser currentUser] refresh];
            if ([[reward className] isEqualToString:@"Reward"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdateRewardList" object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdatePointsRewardList" object:nil];
            } else if ([[reward className] isEqualToString:@"PointReward"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdatePointsRewardList" object:nil];
            }
        } else {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Unable to redeem"
                                                             message:[[error userInfo] objectForKey:@"error"]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
            [alert show];
        }
    }];
}

- (IBAction)redeemButtonClicked:(id)sender {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Are you sure you want to redeem this reward?"
                                                     message:@"Press OK to start the reward redemption process!"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"OK", nil] autorelease];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"OK"]) {
        [self redeemRewards];
    }
}

- (void) dealloc {
    [pictureContainerView release], pictureContainerView = nil;
    [detailsView release], detailsView = nil;
    [countDownTimer release], countDownTimer = nil;
    [countDownLabel release], countDownLabel = nil;
    [descriptionText release], descriptionText = nil;
    [pictureView release], pictureView = nil;
    [redeemButton release], redeemButton = nil;
    [progressView release], progressView = nil;
    [progressParentView release], progressParentView = nil;
    [countDownParentView release], countDownParentView = nil;
    [reward release], reward = nil;
    [countDownDescriptionLabel release], countDownDescriptionLabel = nil;
    [super dealloc];
}

@end
