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

@end

@implementation PointRewardsViewController

@synthesize pointRewardsNavigationController;
@synthesize tabBarController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    self.title = @"Points";
    self.selectedImage = [UIImage imageNamed:@"staron"];
    self.unselectedImage = [UIImage imageNamed:@"staroff"];
    
    self.pointRewardsNavigationController = [[[CustomNavigationController alloc] init] autorelease];
    self.pointRewardsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    PointRewardsTableViewController *pointRewardsTableViewController = [[[PointRewardsTableViewController alloc] init] autorelease];
    [self.pointRewardsNavigationController pushViewController:pointRewardsTableViewController animated:YES];
    [self.view addSubview:self.pointRewardsNavigationController.view];
    self.pointRewardsNavigationController.view.frame = self.view.frame;
    pointRewardsTableViewController.view.frame = self.view.frame;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [pointRewardsNavigationController release], pointRewardsNavigationController = nil;
    [super dealloc];
}
@end
