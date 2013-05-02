//
//  CategoryViewController.m
//  RewardCat
//
//  Created by Chang Liu on 2013-03-22.
//
//

#import "CategoryViewController.h"
#import "CategoryTableViewController.h"
#import "Logger.h"

@interface CategoryViewController ()

@property (nonatomic, retain) CategoryTableViewController *categoryTableViewController;

@end

@implementation CategoryViewController

@synthesize categoryTableViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    self.title = @"RewardCat";

    self.categoryTableViewController = [[[CategoryTableViewController alloc] init] autorelease];
    self.categoryTableViewController.view.frame = self.view.frame;
    [self.view addSubview:self.categoryTableViewController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissCategories) name:@"dismissCategoryView" object:nil];
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isViewLoaded && self.view.window) {
        // this is visible
        [Logger.instance logPageImpression:@"Category"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(dismissCategories)] autorelease];

    [self.navigationItem setHidesBackButton:YES animated:YES];
    [super viewDidAppear:animated];
}

- (void)dismissCategories {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [categoryTableViewController release], categoryTableViewController = nil;
    [super dealloc];
}

@end
