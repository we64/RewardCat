//
//  PointRewardsViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-11-10.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "PointRewardsViewController.h"
#import "PointRewardsTableViewController.h"
#import "CustomNavigationController.h"

@interface PointRewardsViewController ()

@property (nonatomic, retain) CustomNavigationController *pointRewardsNavigationController;
@property (nonatomic, retain) PointRewardsTableViewController *pointRewardsTableViewController;

@end

@implementation PointRewardsViewController

@synthesize pointRewardsNavigationController;
@synthesize pointRewardsTableViewController;
@synthesize tabBarController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    self.title = @"Coins";
    self.selectedImage = [UIImage imageNamed:@"caton"];
    self.unselectedImage = [UIImage imageNamed:@"catoff"];
    
    self.pointRewardsNavigationController = [[[CustomNavigationController alloc] init] autorelease];
    self.pointRewardsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.pointRewardsNavigationController.view.frame = self.view.frame;
    [self.view addSubview:self.pointRewardsNavigationController.view];
    
    self.pointRewardsTableViewController = [[[PointRewardsTableViewController alloc] init] autorelease];
    self.pointRewardsTableViewController.view.frame = self.view.frame;
    [self.pointRewardsNavigationController pushViewController:self.pointRewardsTableViewController animated:YES];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"page_view_tab_coins"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [pointRewardsNavigationController release], pointRewardsNavigationController = nil;
    [pointRewardsTableViewController release], pointRewardsTableViewController = nil;
    [super dealloc];
}
@end
