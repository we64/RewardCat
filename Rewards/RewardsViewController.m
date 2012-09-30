//
//  RewardsViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-09-29.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardsViewController.h"
#import "RewardsTableViewController.h"

@interface RewardsViewController ()

@property (nonatomic, retain) UINavigationController *rewardsNavigationController;
@property (nonatomic, retain) RewardsTableViewController *rewardsTableViewController;

@end

@implementation RewardsViewController

@synthesize rewardsNavigationController, rewardsTableViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    self.title = @"Rewards";
    self.tabBarItem.image = [UIImage imageNamed:@"first"];
    
    self.rewardsNavigationController = [[[UINavigationController alloc] init] autorelease];
    self.rewardsTableViewController = [[[RewardsTableViewController alloc] init] autorelease];
    [self.rewardsNavigationController pushViewController:self.rewardsTableViewController animated:YES];
    [self.view addSubview:self.rewardsNavigationController.view];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)dealloc {
    [rewardsNavigationController release], rewardsNavigationController = nil;
    [rewardsTableViewController release], rewardsTableViewController = nil;
    [super dealloc];
}

@end
