//
//  DetailViewController.h
//  Rewards
//
//  Created by Chang Liu on 2012-10-28.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *detailTableView;

@property (nonatomic, retain) PFObject *reward;

- (id)initWithReward:(PFObject *)reward_;

@end
