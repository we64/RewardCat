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

@interface ScanViewController ()

@property (nonatomic, retain) ZBarReaderViewController *reader;

@end

@implementation ScanViewController

@synthesize reader;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return self;
    }
    self.title = NSLocalizedString(@"Scan", @"Scan");
    self.tabBarItem.image = [UIImage imageNamed:@"second"];
    
    [self login];
    [self setUpCamera];
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.reader.readerView start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.reader.readerView stop];
}

- (void)dealloc {
    [reader release], reader = nil;
    [super dealloc];
}

- (void)setUpCamera {
    [ZBarReaderViewController class];
    self.reader = [[[ZBarReaderViewController alloc] init] autorelease];
    self.reader.readerDelegate = self;
    self.reader.readerView.tracksSymbols = YES;
    self.reader.readerView.trackingColor = [UIColor redColor];
    self.reader.showsZBarControls = NO;
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
    [self.view addSubview:self.reader.view];
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
            NSString *rewardId = [qrData objectAtIndex:1];
            
            PFUser *currentUser = [PFUser currentUser];
            if (![currentUser objectForKey:@"progressMap"]) {
                [currentUser setObject:[NSMutableDictionary dictionary] forKey:@"progressMap"];
            }
            NSMutableDictionary *progressMap = [currentUser objectForKey:@"progressMap"];
            if (!progressMap) {
                progressMap = [NSMutableDictionary dictionary];
            }
            int progress = 0;
            if ([progressMap objectForKey:rewardId]) {
                progress = [[progressMap objectForKey:rewardId] intValue];
            }
            progress++;
            [progressMap setObject:[[NSNumber numberWithInt:progress] stringValue] forKey:rewardId];
            [currentUser save];
            [self.tabBarController setSelectedIndex:1];
        } else {
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

- (void)login {
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [self refresh];
    } else {
        PFUser *user = [PFUser user];
        UIDevice *device = [UIDevice currentDevice];
        NSString *deviceUUID = nil;
        if ([device respondsToSelector:@selector(identifierForVendor)]) {
            deviceUUID = device.identifierForVendor.UUIDString;
        }
        if (deviceUUID == nil || [deviceUUID isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
            deviceUUID = device.uniqueIdentifier;
        }
        user.username = deviceUUID;
        user.password = @"password";
        [user setObject:deviceUUID forKey:@"uuid"];
                
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self refresh];
            } else {
                //TODO: Handle Error
            }
        }];
    }
}

- (void)refresh {
    
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
