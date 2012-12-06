//
//  LoggedInAccountViewController.m
//  RewardCat
//
//  Created by Chang Liu on 2012-11-24.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "LoggedInAccountViewController.h"

@interface LoggedInAccountViewController ()

@end

@implementation LoggedInAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return nil;
    }
    self.title = @"Account";
    
    return self;
}

- (IBAction)likeButtonClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/102527166573589"]];
}

- (IBAction)supportButtonClicked:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        mailer.modalPresentationStyle = UIModalPresentationPageSheet;
        NSArray *toRecipients = [NSArray arrayWithObjects:@"support@rewardcat.com", nil];
        [mailer setToRecipients:toRecipients];
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

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
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

- (IBAction)rateButtonClicked:(id)sender
{
    NSString* url = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", @"584774055"];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
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

@end
