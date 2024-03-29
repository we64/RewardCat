//
//  ScanViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-09-29.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "ScanViewController.h"
#import <Parse/Parse.h>
#import "ZBarReaderView.h"
#import "ZBarReaderViewController.h"
#import "GameUtils.h"
#import "Logger.h"

@interface ScanViewController ()

@property (nonatomic, retain) ZBarReaderViewController *reader;

@end

@implementation ScanViewController

@synthesize reader;
@synthesize scanBox;
@synthesize tabBarController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return self;
    }
    self.title = NSLocalizedString(@"Scan", @"Scan");
    self.selectedImage = [UIImage imageNamed:@"qron"];
    self.unselectedImage = [UIImage imageNamed:@"qroff"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOffCamera) name:@"disableCamera" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOnCamera) name:@"enableCamera" object:nil];
    
    return self;
}

- (void)turnOffCamera {
    [self.reader.readerView stop];
}

- (void)turnOnCamera {
    [self setUpCamera];
    [self.reader.readerView start];
    [Logger.instance logPageImpression:@"Scan"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self turnOnCamera];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self turnOffCamera];
    [GameUtils hideDooberView];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [reader release], reader = nil;
    [scanBox release], scanBox = nil;
    [super dealloc];
}

- (void)setUpCamera {
    if (self.reader == nil) {
        [ZBarReaderViewController class];
        self.reader = [[[ZBarReaderViewController alloc] init] autorelease];
        self.reader.readerDelegate = self;
        self.reader.readerView.tracksSymbols = YES;
        self.reader.readerView.trackingColor = [UIColor redColor];
        self.reader.showsZBarControls = NO;
        self.reader.showsCameraControls = NO;
        self.reader.supportedOrientationsMask = ZBarOrientationMaskAll;
        self.reader.wantsFullScreenLayout = NO;
        self.reader.readerView.torchMode = NO;
        
        [self.reader.scanner setSymbology: 0
                                   config: ZBAR_CFG_ENABLE
                                       to: 0];
        [self.reader.scanner setSymbology: ZBAR_QRCODE
                                   config: ZBAR_CFG_ENABLE
                                       to: 1];

        self.view.frame = CGRectMake(self.tabBarController.view.frame.origin.x,
                                     self.tabBarController.view.frame.origin.y,
                                     self.tabBarController.view.frame.size.width,
                                     self.tabBarController.view.frame.size.height);
        self.reader.view.frame = self.view.frame;
        if (self.reader.view.subviews.count == 2) {
            ((UIView *)self.reader.view.subviews.lastObject).hidden = YES;
            ((UIView *)[self.reader.view.subviews objectAtIndex:0]).frame = self.reader.view.frame;
        }
        [self.view insertSubview:self.reader.view belowSubview:self.scanBox];
    }
}

- (void)readerControllerDidFailToRead:(ZBarReaderController *)reader withRetry:(BOOL)retry {
    NSLog(@"Failed to read");
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    id <NSFastEnumeration> syms = [info objectForKey: ZBarReaderControllerResults];
    for(ZBarSymbol *sym in syms) {
        NSLog(@"%@", sym.data);
        NSArray *qrData = [sym.data componentsSeparatedByString:@"?r="];
        if ([[[qrData objectAtIndex:0] lowercaseString] isEqualToString:@"http://www.rewardcat.com"] && qrData.count >= 2) {
            [[Logger instance] logEvent:@"action_start_scan_valid_qr_code"];

            NSString *rewardId = [qrData objectAtIndex:1];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:rewardId, @"rewardID", nil];
            [GameUtils showProcessing];
            [PFCloud callFunctionInBackground:@"IncrementProgress" withParameters:dictionary block:^(id result, NSError *error) {
                [GameUtils hideProgressing];

                if (!error) {
                    [GameUtils refreshCurrentUser];
                    [[Logger instance] logEvent:@"action_end_scan_valid_qr_code_successfully"];
                    PFObject *pointRewardToShow = (PFObject *)[result objectForKey:@"pointRewardToShow"];
                    [pointRewardToShow setObject:[result objectForKey:@"pointRewardToShowObjectId"] forKey:@"objectId"];
                    [GameUtils showDoobersWithStamp:[[result objectForKey:@"rewardDelta"] intValue]
                                               coin:[[result objectForKey:@"rewardcatPointsDelta"] intValue]
                                         vendorName:[[[GameUtils instance].vendorDictionary objectForKey:[result objectForKey:@"vendorId"]] objectForKey:@"name"]
                                      inviteMessage:[result objectForKey:@"inviteMessage"]
                                        pointReward:pointRewardToShow
                                 instructionMessage:[result objectForKey:@"instructionMessage"]];
                } else {
                    // scan unsuccessful, show error message
                    // if it is due to scanning too soon, show Invalid Scan
                    [[Logger instance] logEvent:@"action_end_scan_valid_qr_code_error"];
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    NSRange isContains = [errorString rangeOfString:@"For security reasons" options:NSCaseInsensitiveSearch];
                    if(isContains.location != NSNotFound) {
                        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Invalid Scan"
                                                                         message:[[error userInfo] objectForKey:@"error"]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil] autorelease];
                        [alert show];
                    } else {
                        // TODO: Ask Garry to write some message here
                        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Invalid Scan"
                                                                         message:[[error userInfo] objectForKey:@"error"]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil] autorelease];
                        [alert show];
                    }
                }
            }];
        } else {
            [[Logger instance] logEvent:@"action_scan_invalid_qr_code"];
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Invalid QR code"
                                                             message:@"This is not a valid Reward Cat QR code."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
            [alert show];
        }
        break;
    }
}

@end
