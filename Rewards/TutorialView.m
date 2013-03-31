//
//  TutorialView.m
//  RewardCat
//
//  Created by Chang Liu on 2013-02-23.
//
//

#import "TutorialView.h"
#import "RewardCatTabBarController.h"
#import "GameUtils.h"

@implementation TutorialView

@synthesize next;
@synthesize previous;
@synthesize dots;
@synthesize tutorialViews;
@synthesize page;
@synthesize finish;
@synthesize showFacebookPage;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [next release], next = nil;
    [previous release], previous = nil;
    [finish release], finish = nil;
    [dots release], dots = nil;
    [tutorialViews release], tutorialViews = nil;
    [super dealloc];
}

- (void)setPage:(int)page_ {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishClicked) name:@"dismissTutorialView" object:nil];
    int pageCount = MIN(self.tutorialViews.count, self.dots.count);
    if (pageCount <= 0) {
        return;
    }
    if (page < 0) {
        page = 0;
    }
    if (page >= pageCount) {
        [self removeFromSuperview];
    }
    page = page_;
    for (int i = 0; i < pageCount; i++) {
        ((UIView *)[self.tutorialViews objectAtIndex:i]).hidden = i != page;
        ((UIImageView *)[self.dots objectAtIndex:i]).alpha = i == page ? 1 : 0.5;
    }
    
    NSString *skipText = @"skip";
    int pagesToSkip = 0;
    if (!self.showFacebookPage) {
        pagesToSkip++;
        skipText = @"done";
    }
    [finish setTitle:skipText forState:UIControlStateNormal];
    self.next.hidden = page >= pageCount - 1 - pagesToSkip;
    self.finish.hidden = page < pageCount - 1 - pagesToSkip;
    self.previous.hidden = page <= 0;
    
    for (UIImageView *dot in self.dots) {
        dot.hidden = pageCount - pagesToSkip <= 1;
    }
    
    RewardCatTabBarController *tabBarController = [GameUtils instance].tabBarController;
    tabBarController.selectedIndex = 2;
}

- (IBAction)nextClicked {
    self.page++;
}

- (IBAction)previousClicked {
    self.page--;
}

- (IBAction)finishClicked {
    [self removeFromSuperview];
}

- (IBAction)signInWithFacebook:(id)sender {
    PFUser *oldUser = [PFUser currentUser];
    [PFFacebookUtils logInWithPermissions:[GameUtils instance].facebookPermissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else {
            NSLog(@"User with facebook logged in!");
            [[GameUtils instance] mergeDefaultAccountWithFacebookOrSignedUp:user actionType:@"facebook" previousUser:oldUser showDialog:NO];
        }
    }];
}

@end
