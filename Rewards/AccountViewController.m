//
//  AccountViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-11-10.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "AccountViewController.h"


@interface AccountViewController ()

@property (nonatomic, retain) UINavigationController *accountNavigationController;

@end

@implementation AccountViewController

@synthesize accountNavigationController;
@synthesize tabBarController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    self.title = @"Account";
    self.selectedImage = [UIImage imageNamed:@"personon"];
    self.unselectedImage = [UIImage imageNamed:@"personoff"];
    
    self.accountNavigationController = [[[UINavigationController alloc] init] autorelease];
    self.accountNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    LoggedInAccountViewController *loggedInAccountViewController = [[[LoggedInAccountViewController alloc] init] autorelease];
    [self.accountNavigationController pushViewController:loggedInAccountViewController animated:YES];
    loggedInAccountViewController.view.frame = self.view.frame;
    
    [self.view addSubview:self.accountNavigationController.view];
    self.accountNavigationController.view.frame = self.view.frame;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    PFUser *user = [PFUser currentUser];
    NSString *deviceUUID = [user objectForKey:@"uuid"];
    if ([deviceUUID isEqualToString:[user username]]) {
        SignUpLogInViewController *signUpLogInViewController = [[[SignUpLogInViewController alloc] init] autorelease];
        [self.accountNavigationController pushViewController:signUpLogInViewController animated:YES];
        signUpLogInViewController.view.frame = self.view.frame;
    }
}

- (void)dealloc
{
    [accountNavigationController release], accountNavigationController = nil;
    [super dealloc];
}

@end
