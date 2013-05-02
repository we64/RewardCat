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
#import "GameUtils.h"
#import "Logger.h"

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
    self.title = @"Loyalty";
    self.selectedImage = [UIImage imageNamed:@"stampon"];
    self.unselectedImage = [UIImage imageNamed:@"stampoff"];
    
    self.rewardsNavigationController = [[[CustomNavigationController alloc] init] autorelease];
    self.rewardsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    RewardsTableViewController *rewardsTableViewController = [[[RewardsTableViewController alloc] init] autorelease];
    [self.rewardsNavigationController pushViewController:rewardsTableViewController animated:YES];
    [self.view addSubview:self.rewardsNavigationController.view];
    self.rewardsNavigationController.view.frame = self.view.frame;
    rewardsTableViewController.view.frame = self.view.frame;
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isViewLoaded && self.view.window) {
        // this is visible
        [Logger.instance logPageImpression:@"Loyalty"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [rewardsNavigationController release], rewardsNavigationController = nil;
    [super dealloc];
}

@end
