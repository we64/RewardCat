//
//  CustomNavigationController.m
//  RewardCat
//
//  Created by Chang Liu on 2012-12-27.
//
//

#import "CustomNavigationController.h"
#import "DetailViewController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
	if([[self.viewControllers lastObject] class] == [DetailViewController class]) {
        DetailViewController *detailViewController = (DetailViewController *)[self.viewControllers lastObject];
        if (detailViewController.redeem) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:detailViewController.reward.objectId, @"rewardID", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"finishedRedeemReward" object:nil userInfo:dictionary];
        }
		return [super popViewControllerAnimated:animated];
	} else {
		return [super popViewControllerAnimated:animated];
	}
}

@end
