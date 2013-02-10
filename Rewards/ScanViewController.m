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

@interface ScanViewController ()

@property (nonatomic, retain) ZBarReaderViewController *reader;

@end

@implementation ScanViewController

@synthesize reader;
@synthesize scanBox;
@synthesize tabBarController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return self;
    }
    self.title = NSLocalizedString(@"Scan", @"Scan");
    self.selectedImage = [UIImage imageNamed:@"qron"];
    self.unselectedImage = [UIImage imageNamed:@"qroff"];

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [Flurry logEvent:@"page_view_tab_scan"];
    if (![self userLoggedIn]) {
        [self login];
    }

    [self setUpCamera];
    [self.reader.readerView start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.reader.readerView stop];
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
            [Flurry logEvent:@"action_scan_valid_qr_code"];
            [Flurry logEvent:@"action_scan_valid_qr_code_duration" timed:YES];

            NSString *rewardId = [qrData objectAtIndex:1];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:rewardId, @"rewardID", nil];
            [GameUtils showProcessing];
            [PFCloud callFunctionInBackground:@"IncrementProgress" withParameters:dictionary block:^(id result, NSError *error) {
                [GameUtils hideProgressing];
                [Flurry endTimedEvent:@"action_scan_valid_qr_code_duration" withParameters:nil];
                if (!error) {
                    [GameUtils refreshCurrentUser];
                    [GameUtils showDoobersWithStamp:[[((NSDictionary *)result) objectForKey:@"rewardDelta"] intValue]
                                               coin:[[((NSDictionary *)result) objectForKey:@"rewardcatPointsDelta"] intValue]
                                         vendorName:[[[GameUtils instance].vendorDictionary objectForKey:[result objectForKey:@"vendorId"]] objectForKey:@"name"]];
                } else {
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Invalid Scan"
                                                                     message:[[error userInfo] objectForKey:@"error"]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil] autorelease];
                    [alert show];
                }
            }];
        } else {
            [Flurry logEvent:@"error_action_scan_invalid_qr_code"];
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

//- (NSString *)deviceUUID {
//    UIDevice *device = [UIDevice currentDevice];
//    NSString *deviceUUID = nil;
//    if ([device respondsToSelector:@selector(identifierForVendor)]) {
//        deviceUUID = device.identifierForVendor.UUIDString;
//    }
//    if (deviceUUID == nil || [deviceUUID isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
//        deviceUUID = device.uniqueIdentifier;
//    }
//    return deviceUUID;
//}

- (void)signup {
    self.tabBarController.selectedIndex = 4;
    PFUser *user = [PFUser user];
    user.username = [GameUtils uuid];
    user.password = @"password";
    [user setObject:[GameUtils uuid] forKey:@"uuid"];
    [user setObject:[NSMutableDictionary dictionary] forKey:@"progressMap"];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [GameUtils refreshCurrentUser];
        } else {
            //TODO: Handle Error
            NSLog(@"%@", error);
        }
    }];
}

- (void)login {
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation saveInBackground];
    if ([self userLoggedIn]) {
        [GameUtils refreshCurrentUser];
    } else {
        [PFUser logInWithUsernameInBackground:[GameUtils uuid] password:@"password" block:^(PFUser *user, NSError *error) {
            if (!error) {
                [GameUtils refreshCurrentUser];
            } else {
                [self signup];
            }
        }];
    }
}

- (BOOL)userLoggedIn {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        return true;
    } else {
        return false;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
