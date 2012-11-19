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
#import "Reachability.h"

@interface ScanViewController ()

@property (nonatomic, retain) ZBarReaderViewController *reader;

@end

@implementation ScanViewController

@synthesize reader;
@synthesize scanBox;

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
    if (![self userLoggedIn]) {
        if ([self connected]) {
            [self login];
        } else {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Internet Connection Error"
                                                             message:@"Please use RewardCat with internet connection."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil] autorelease];
            [alert show];
        }
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
        if ([[[qrData objectAtIndex:0] lowercaseString] isEqualToString:@"http://www.rewardcat.com"]) {
            [Flurry logEvent:@"Scanned Valid QR code"];
            NSString *rewardId = [qrData objectAtIndex:1];
            NSArray *keys = [NSArray arrayWithObjects:@"rewardID", nil];
            NSArray *objects = [NSArray arrayWithObjects:rewardId, nil];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects
                                                                   forKeys:keys];
            [PFCloud callFunctionInBackground:@"IncrementProgress" withParameters:dictionary block:^(id result, NSError *error) {
                if (!error) {
                    [Flurry logEvent:@"Scanned Valid QR code and saved successfully to server"];
                    [self refresh];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdateRewardList" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldUpdatePointsRewardList" object:nil];
                } else {
                    [Flurry logEvent:@"Scanned Valid QR code but rejected by server"];
                    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Invalid Scan"
                                                                     message:[[error userInfo] objectForKey:@"error"]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil] autorelease];
                    [alert show];
                }
            }];

            self.tabBarController.selectedIndex = 1;
        } else {
            [Flurry logEvent:@"Scanned Invalid QR code"];
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

- (NSString *)deviceUUID {
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceUUID = nil;
    if ([device respondsToSelector:@selector(identifierForVendor)]) {
        deviceUUID = device.identifierForVendor.UUIDString;
    }
    if (deviceUUID == nil || [deviceUUID isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        deviceUUID = device.uniqueIdentifier;
    }
    return deviceUUID;
}

- (void)signup {
    PFUser *user = [PFUser user];
    user.username = [self deviceUUID];
    user.password = @"password";
    [user setObject:[self deviceUUID] forKey:@"uuid"];
    [user setObject:[NSMutableDictionary dictionary] forKey:@"progressMap"];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self refresh];
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
        [self refresh];
    } else {
        [PFUser logInWithUsernameInBackground:[self deviceUUID] password:@"password" block:^(PFUser *user, NSError *error) {
            if (!error) {
                [self refresh];
            } else {
                [self signup];
            }
        }];
    }
}

- (void)refresh {
    [[PFUser currentUser] refresh];
}

- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

- (BOOL)userLoggedIn
{
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
