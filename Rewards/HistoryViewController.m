//
//  HistoryViewController.m
//  RewardCat
//
//  Created by Chang Liu on 2013-02-18.
//
//

#import "HistoryViewController.h"
#import "HistoryTableViewController.h"

@interface HistoryViewController ()

@property (nonatomic, retain) HistoryTableViewController *historyTableViewController;

@end

@implementation HistoryViewController

@synthesize historyTableViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    self.title = @"Transaction";
    
    self.historyTableViewController = [[[HistoryTableViewController alloc] init] autorelease];
    self.historyTableViewController.view.frame = self.view.frame;
    [self.view addSubview:self.historyTableViewController.view];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)dealloc {
    [historyTableViewController release], historyTableViewController = nil;
    [super dealloc];
}

@end
