//
//  RewardCatTabBarController.m
//  RewardCat
//
//  Created by Chang Liu on 2012-11-18.
//  Copyright (c) 2012 TZ. All rights reserved.
//

#import "RewardCatTabBarController.h"
#import "RewardCatViewController.h"

@interface RewardCatTabBarController ()

@property (nonatomic, retain) NSMutableArray *iconViews;

@end

@implementation RewardCatTabBarController

@synthesize iconViews;

- (void)refresh {
    int index = 0;
    for (RewardCatViewController *viewController in self.viewControllers) {
        UIImage *iconImage;
        if (self.selectedViewController == viewController) {
            iconImage = viewController.selectedImage;
        } else {
            iconImage = viewController.unselectedImage;
        }
        UIImageView *iconView = [self.iconViews objectAtIndex:index];
        iconView.image = iconImage;
        index++;
    }
}

#define iconWith 60
#define iconXSpacing 64
#define iconHeight 35
#define iconX 2
#define iconY 1

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    [super setSelectedViewController:selectedViewController];
    [self refresh];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    [self refresh];
}

- (void)setViewControllers:(NSArray *)viewControllers_ {
    [super setViewControllers:viewControllers_];
    
    for (UIImageView *iconView in self.iconViews) {
        [iconView removeFromSuperview];
    }
    self.iconViews = [NSMutableArray array];
    int index = 0;
    for (RewardCatViewController *viewController in self.viewControllers) {
        UIImage *iconImage;
        if (self.selectedViewController == viewController) {
            iconImage = viewController.selectedImage;
        } else {
            iconImage = viewController.unselectedImage;
        }
        UIImageView *iconView = [[[UIImageView alloc] initWithImage:iconImage] autorelease];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.frame = CGRectMake(index *iconXSpacing + iconX, iconY, iconWith, iconHeight);
        [self.iconViews addObject:iconView];
        [self.tabBar addSubview:iconView];
        index++;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self refresh];
}

- (void)dealloc {
    [iconViews release], iconViews = nil;
    [super dealloc];
}

@end
