//
//  SignUpViewController.m
//  RewardCat
//
//  Created by Chang Liu on 2012-11-23.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "SignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"

@interface SignUpViewController ()

@property (nonatomic, retain) UIImageView *fieldsBackground;
@property (nonatomic, retain) UIImageView *background;
@property (nonatomic, retain) UIDatePicker *datePicker;

@end

@implementation SignUpViewController

@synthesize fieldsBackground;
@synthesize background;
@synthesize datePicker;
@synthesize birthday;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Sign Up";
    datePicker = [[UIDatePicker alloc] init];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setMaximumDate:[NSDate date]];
    [datePicker setDate:[[NSDate date] dateByAddingTimeInterval:-4650*24*60*60]];
    [datePicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
    [self.signUpView.additionalField setInputView:datePicker];
    
    [self.signUpView setLogo:nil];
    
    [self.signUpView.signUpButton setBackgroundImage:[UIImage imageNamed:@"signinup.png"] forState:UIControlStateNormal];
    self.signUpView.signUpButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    
    UIImageView *logInFieldBackgroundView = [self.signUpView.subviews objectAtIndex:0];
    [logInFieldBackgroundView removeFromSuperview];
    self.fieldsBackground = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"4box.png"]] autorelease];
    
    // hack for parse's retardedness for doing things differently on 4.3
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] > 5) {
        self.fieldsBackground.frame = CGRectMake(42.5, 60, 235, 180);
    } else {
        self.fieldsBackground.frame = CGRectMake(42.5, 85, 235, 180);
    }
    [self.signUpView insertSubview:self.fieldsBackground atIndex:0];
    
    self.background = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alum.png"]] autorelease];
    self.background.frame = CGRectMake(0, 0, 320, 568);
    [self.signUpView insertSubview:self.background atIndex:0];
    
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    self.signUpView.signUpButton.adjustsImageWhenHighlighted = YES;
    
    [self.signUpView.additionalField setPlaceholder:@"Birthday"];
    [self.signUpView.usernameField setValue:[UIColor colorWithWhite:1 alpha:0.75] forKeyPath:@"_placeholderLabel.textColor"];
    [self.signUpView.passwordField setValue:[UIColor colorWithWhite:1 alpha:0.75] forKeyPath:@"_placeholderLabel.textColor"];
    [self.signUpView.emailField setValue:[UIColor colorWithWhite:1 alpha:0.75] forKeyPath:@"_placeholderLabel.textColor"];
    [self.signUpView.additionalField setValue:[UIColor colorWithWhite:1 alpha:0.75] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.signUpView.usernameField.font = [UIFont systemFontOfSize:20];
    self.signUpView.passwordField.font = [UIFont systemFontOfSize:20];
    self.signUpView.emailField.font = [UIFont systemFontOfSize:20];
    self.signUpView.additionalField.font = [UIFont systemFontOfSize:20];
    
    self.signUpView.usernameField.textColor = [UIColor whiteColor];
    self.signUpView.passwordField.textColor = [UIColor whiteColor];
    self.signUpView.emailField.textColor = [UIColor whiteColor];
    self.signUpView.additionalField.textColor = [UIColor whiteColor];
    
    self.signUpView.usernameField.layer.shadowOpacity = 1;
    self.signUpView.passwordField.layer.shadowOpacity = 1;
    self.signUpView.emailField.layer.shadowOpacity = 1;
    self.signUpView.additionalField.layer.shadowOpacity = 1;
    
    self.signUpView.usernameField.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.signUpView.passwordField.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.signUpView.emailField.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.signUpView.additionalField.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    self.signUpView.usernameField.layer.shadowRadius = 0;
    self.signUpView.passwordField.layer.shadowRadius = 0;
    self.signUpView.emailField.layer.shadowRadius = 0;
    self.signUpView.additionalField.layer.shadowRadius = 0;
    
    self.signUpView.usernameField.layer.opacity = 1;
    self.signUpView.passwordField.layer.opacity = 1;
    self.signUpView.emailField.layer.opacity = 1;
    self.signUpView.additionalField.layer.opacity = 1;
}

- (void)viewDidLayoutSubviews {
    self.signUpView.usernameField.frame = CGRectMake(42.5, 60, 235, 45);
    self.signUpView.passwordField.frame = CGRectMake(42.5, 105, 235, 45);
    self.signUpView.emailField.frame = CGRectMake(42.5, 150, 235, 45);
    self.signUpView.additionalField.frame = CGRectMake(42.5, 195, 235, 45);
    self.signUpView.signUpButton.frame = CGRectMake(40, 260, 240, 50);
    self.signUpView.signUpButton.contentEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 0);
}

- (void)pickerChanged:(id)sender
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    self.signUpView.additionalField.text = [formatter stringFromDate:[datePicker date]];
    self.birthday = [datePicker date];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"page_view_signup"];
}

- (void)dealloc {
    [background release], background = nil;
    [fieldsBackground release], fieldsBackground = nil;
    [datePicker release], datePicker = nil;
    [birthday release], birthday = nil;
    [super dealloc];
}

@end
