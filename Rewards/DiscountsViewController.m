//
//  DiscountViewController.m
//  RewardCat
//
//  Created by Chang Liu on 2013-02-17.
//
//

#import "DiscountsViewController.h"
#import "CustomNavigationController.h"
#import "DiscountsTableViewController.h"
#import "Logger.h"

@interface DiscountsViewController ()

@property (nonatomic, retain) CustomNavigationController *discountsNavigationController;

@end

@implementation DiscountsViewController

@synthesize discountsNavigationController;
@synthesize tabBarController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    self.title = @"Discounts";
    self.selectedImage = [UIImage imageNamed:@"tagon"];
    self.unselectedImage = [UIImage imageNamed:@"tagoff"];
    
    self.discountsNavigationController = [[[CustomNavigationController alloc] init] autorelease];
    self.discountsNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    DiscountsTableViewController *discountsTableViewController = [[[DiscountsTableViewController alloc] init] autorelease];
    [self.discountsNavigationController pushViewController:discountsTableViewController animated:YES];
    [self.view addSubview:self.discountsNavigationController.view];
    self.discountsNavigationController.view.frame = self.view.frame;
    discountsTableViewController.view.frame = self.view.frame;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isViewLoaded && self.view.window) {
        // this is visible
        [Logger.instance logPageImpression:@"Discount"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [discountsNavigationController release], discountsNavigationController = nil;
    [super dealloc];
}

@end
