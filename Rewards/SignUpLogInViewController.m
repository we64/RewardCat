//
//  SignUpLogInViewController.m
//  RewardCat
//
//  Created by Chang Liu on 2012-11-23.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "SignUpLogInViewController.h"
#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SignUpLogInViewController ()

@property (nonatomic, retain) UIImageView *fieldsBackground;
@property (nonatomic, retain) UIImageView *background;
@property (nonatomic, retain) PFUser *beforeLoggedInUser;

@end

@implementation SignUpLogInViewController

@synthesize fieldsBackground;
@synthesize background;
@synthesize beforeLoggedInUser;

- (id)init {
    [super init];
    if (!self) {
        return self;
    }
    self.title = @"Account";
    [self.navigationItem setHidesBackButton:YES];
    
    [self setDelegate:self];
    [self setFacebookPermissions:[NSArray arrayWithObjects:@"user_birthday", @"friends_about_me", nil]];
    [self setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsPasswordForgotten | PFLogInFieldsFacebook];

    // this is hack to get Facebook/Twitter user login to work
    PFUser *user = [PFUser currentUser];
    if ([user.username isEqualToString:[user objectForKey:@"uuid"]]) {
        self.beforeLoggedInUser = user;
    }
    
    UIBarButtonItem *signUpButton = [[[UIBarButtonItem alloc]
                                    initWithTitle:@"Sign Up"
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(signUpButtonClicked:)] autorelease];
    self.navigationItem.rightBarButtonItem = signUpButton;
    return self;
}

- (IBAction)signUpButtonClicked:(id)sender {
    // Create the sign up view controller
    SignUpViewController *signUpViewController = [[[SignUpViewController alloc] init] autorelease];
    [signUpViewController setDelegate:self];
    [signUpViewController setFields:PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsEmail | PFSignUpFieldsSignUpButton | PFSignUpFieldsAdditional];
    
    [[self navigationController] pushViewController:signUpViewController animated:YES];
}

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        return YES;
    }
    
    [[[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] autorelease] show];
    return NO;
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    // this is hack to get Facebook/Twitter user login to work
    // TODO: should do a merge of the existing progressMap and the logged in user progressMap to preserve scans
    NSMutableDictionary *progress = [user objectForKey:@"progressMap"];
    if (!progress) {
        [user setObject:[self.beforeLoggedInUser objectForKey:@"progressMap"] forKey:@"progressMap"];
        [user setObject:[self.beforeLoggedInUser objectForKey:@"uuid"] forKey:@"uuid"];
        if ([self.beforeLoggedInUser objectForKey:@"rewardcatPoints"]) {
            [user setObject:[self.beforeLoggedInUser objectForKey:@"rewardcatPoints"] forKey:@"rewardcatPoints"];
        }
        [user save];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdateRewardList" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdatePointsRewardList" object:nil];
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Log in failed...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    } else {
        // check to see if username already exists
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:[info objectForKey:@"username"]];
        
        if ([query countObjects] <= 0) {
            // custom sign up
            [[PFUser currentUser] setUsername:[info objectForKey:@"username"]];
            [[PFUser currentUser] setPassword:[info objectForKey:@"password"]];
            [[PFUser currentUser] setEmail:[info objectForKey:@"email"]];
            [[PFUser currentUser] setObject:[(SignUpViewController *)signUpController birthday] forKey:@"birthday"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    [[PFUser currentUser] refresh];
                } else {
                    NSLog(@"User Sign Up saving error");
                }
            }];
            informationComplete = NO;
            
            self.navigationItem.rightBarButtonItem = nil;
            [[self navigationController] popToRootViewControllerAnimated:YES];
        }
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    NSLog(@"User signed up, send back to delegate...");
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController...");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.logInView setLogo:nil];
    
    UIImageView *logInFieldBackgroundView = [self.logInView.subviews objectAtIndex:0];
    [logInFieldBackgroundView removeFromSuperview];
    self.fieldsBackground = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2box.png"]] autorelease];
    self.fieldsBackground.frame = CGRectMake(42.5, 60, 235, 90);
    [self.logInView insertSubview:self.fieldsBackground atIndex:0];
    
    self.background = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alum.png"]] autorelease];
    self.background.frame = CGRectMake(0, 0, 320, 568);
    [self.logInView insertSubview:self.background atIndex:0];
    
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    [self.logInView.facebookButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setTitle:@"Facebook" forState:UIControlStateNormal];
    self.logInView.facebookButton.adjustsImageWhenHighlighted = TRUE;
    self.logInView.facebookButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    
    [self.logInView.passwordForgottenButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setBackgroundImage:[UIImage imageNamed:@"forgot.png"] forState:UIControlStateNormal];
    [self.logInView.passwordForgottenButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    self.logInView.passwordForgottenButton.adjustsImageWhenHighlighted = TRUE;
    
    self.logInView.externalLogInLabel.textColor = [UIColor whiteColor];
    [self.logInView.usernameField setValue:[UIColor colorWithWhite:1 alpha:0.75] forKeyPath:@"_placeholderLabel.textColor"];
    [self.logInView.passwordField setValue:[UIColor colorWithWhite:1 alpha:0.75] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.logInView.usernameField.font = [UIFont systemFontOfSize:20];
    self.logInView.passwordField.font = [UIFont systemFontOfSize:20];
    
    self.logInView.usernameField.textColor = [UIColor whiteColor];
    self.logInView.passwordField.textColor = [UIColor whiteColor];
    
    self.logInView.usernameField.layer.shadowOpacity = 1;
    self.logInView.passwordField.layer.shadowOpacity = 1;
    
    self.logInView.usernameField.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.logInView.passwordField.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    self.logInView.usernameField.layer.shadowRadius = 0;
    self.logInView.passwordField.layer.shadowRadius = 0;
    
    self.logInView.usernameField.layer.opacity = 1;
    self.logInView.passwordField.layer.opacity = 1;
}

- (void)viewDidLayoutSubviews {
    self.logInView.usernameField.frame = CGRectMake(42.5, 60, 235, 45);
    self.logInView.passwordField.frame = CGRectMake(42.5, 105, 235, 45);
    
    self.logInView.externalLogInLabel.frame = CGRectMake(40, 150, 240, 45);
    self.logInView.facebookButton.frame = CGRectMake(100, 195, 120, 50);
    
    self.logInView.passwordForgottenButton.frame = CGRectMake(19.5, 77.5, 23, 55);
}

- (void)dealloc {
    [fieldsBackground release], fieldsBackground = nil;
    [background release], background = nil;
    [beforeLoggedInUser release], beforeLoggedInUser = nil;
    [super dealloc];
}

@end
