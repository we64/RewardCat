//
//  ScanViewController.m
//  Rewards
//
//  Created by Chang Liu on 2012-09-29.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "ScanViewController.h"
#import <Parse/Parse.h>

@interface ScanViewController ()

@end

@implementation ScanViewController

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
        
        NSMutableDictionary *progress = [NSMutableDictionary dictionary];
        [user setObject:progress forKey:@"progressMap"];
        
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
