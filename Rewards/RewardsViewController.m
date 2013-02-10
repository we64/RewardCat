//
//  RewardsViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-09-29.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardsViewController.h"
#import "RewardsTableViewController.h"
#import "CustomNavigationController.h"

@interface RewardsViewController ()

@property (nonatomic, retain) CustomNavigationController *rewardsNavigationController;

@end

@implementation RewardsViewController

@synthesize rewardsNavigationController;
@synthesize tabBarController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    self.title = @"Rewards";
    self.selectedImage = [UIImage imageNamed:@"couponon"];
    self.unselectedImage = [UIImage imageNamed:@"couponoff"];
    
    self.rewardsNavigationController = [[[CustomNavigationController alloc] init] autorelease];
    self.rewardsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    RewardsTableViewController *rewardsTableViewController = [[[RewardsTableViewController alloc] init] autorelease];
    [self.rewardsNavigationController pushViewController:rewardsTableViewController animated:YES];
    [self.view addSubview:self.rewardsNavigationController.view];
    self.rewardsNavigationController.view.frame = self.view.frame;
    rewardsTableViewController.view.frame = self.view.frame;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"page_view_tab_rewards"];
}

- (void)dealloc {
    [rewardsNavigationController release], rewardsNavigationController = nil;
    [super dealloc];
}

@end
