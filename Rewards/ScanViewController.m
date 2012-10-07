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
@synthesize tabViewSwitchingDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) {
        return self;
    }
    self.title = NSLocalizedString(@"Scan", @"Scan");
    self.tabBarItem.image = [UIImage imageNamed:@"second"];
    
    [self login];
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [self setUpCamera];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.reader.view removeFromSuperview];
}

- (void)dealloc {
    [reader release], reader = nil;
    [tabViewSwitchingDelegate release], tabViewSwitchingDelegate = nil;
    [super dealloc];
}

- (void)setUpCamera {
    [ZBarReaderViewController class];
    self.reader = [[[ZBarReaderViewController alloc] init] autorelease];
    self.reader.readerDelegate = self;
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
        if ([[qrData objectAtIndex:0] isEqualToString:@"http://www.rewardCat.com"]) {
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
            [self.tabViewSwitchingDelegate switchToTab:1];
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
        NSString *uuid;
        if ([device respondsToSelector:@selector(identifierForVendor)]) {
            uuid = device.identifierForVendor.UUIDString;
        } else {
            uuid = device.uniqueIdentifier;
        }
        user.username = uuid;
        user.password = @"password";
        [user setObject:uuid forKey:@"uuid"];
                
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self refresh];
            } else {
                //TODO: Handle error
                //NSString *errorString = [[error userInfo] objectForKey:@"error"];
                // Show the errorString somewhere and let the user try again.
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
