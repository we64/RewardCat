//
//  LoggedInAccountViewController.m
//  RewardCat
//
//  Created by Chang Liu on 2012-11-24.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "LoggedInAccountViewController.h"
#import "AccountTableViewCell.h"
#import "HistoryViewController.h"
#import "GameUtils.h"

@interface LoggedInAccountViewController ()

@property (nonatomic) CGFloat cellHeight;

@end

@implementation LoggedInAccountViewController

@synthesize accountTableView;
@synthesize cellHeight;
@synthesize accountNavigationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    self.title = @"Account";
    
    static NSString *CellIdentifier = @"AccountTableViewCell";
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
    AccountTableViewCell *cell = [nib objectAtIndex:0];
    
    self.cellHeight = cell.frame.size.height;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    [accountTableView release], accountTableView = nil;
    [super dealloc];
}

- (void)historyButtonClicked {
    HistoryViewController *historyViewController = [[[HistoryViewController alloc] init] autorelease];
    historyViewController.view.frame = self.view.frame;
    [self.accountNavigationController pushViewController:historyViewController animated:YES];
}

- (void)likeButtonClicked {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/102527166573589"]];
}

- (void)supportButtonClicked {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        NSArray *toRecipients = [NSArray arrayWithObjects:@"support@rewardcat.com", nil];
        [mailer setToRecipients:toRecipients];
        
        NSMutableString *mailBody = [NSMutableString string];
        int iOSVersion = [[UIDevice currentDevice].systemVersion intValue];
        [mailBody appendString:@"<BR><BR><BR>\n"];
        [mailBody appendString:@"<div>The following information are used to help us to better serve your needs:</div>\n"];
        [mailBody appendString:[NSString stringWithFormat:@"<div>username: %@</div>\n", [PFUser currentUser].username]];
        [mailBody appendString:[NSString stringWithFormat:@"<div>iOS Version: %d</div>\n", iOSVersion]];
        [mailer setMessageBody:mailBody isHTML:YES];
        [self presentModalViewController:mailer animated:YES];
        [mailer release];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Email"
                                                        message:@"This device is not yet configured for sending emails. You can reach us from other devices by emailing us at support@rewardcat.com"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }

    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}

- (void)rateButtonClicked {
    [GameUtils goToAppStore];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        return nil;
    }
    
    static NSString *CellIdentifier = @"AccountTableViewCell";
    
    AccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    AccountTableCellPosition position;
    if (indexPath.row == 0) {
        position = TableTop;
    } else if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        position = TableBottom;
    } else {
        position = TableMiddle;
    }
    
    [cell setUpWithType:indexPath.row position:position parent:self];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellHeight;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return AccountTableCellTypeCount;
    }
    
    return 0;
}

@end
