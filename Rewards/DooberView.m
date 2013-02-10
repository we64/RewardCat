//
//  DooberView.m
//  RewardCat
//
//  Created by Chang Liu on 2013-01-26.
//
//

#import "DooberView.h"

@implementation DooberView

@synthesize coinView;
@synthesize stampView;
@synthesize coinLabel;
@synthesize stampLabel;
@synthesize stampVendorLabel;

- (void)dealloc {
    [coinView release], coinView = nil;
    [stampView release], stampView = nil;
    [stampLabel release], stampLabel = nil;
    [coinLabel release], coinLabel = nil;
    [stampVendorLabel release], stampVendorLabel = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)showWithStamp:(int)stamp coin:(int)coin vendorName:(NSString *)vendorName {
    self.stampView.hidden = stamp <= 0;
    self.coinView.hidden = coin <= 0;
    self.stampLabel.text = [NSString stringWithFormat:@"%d", stamp];
    self.coinLabel.text = [NSString stringWithFormat:@"%d", coin];
    self.stampVendorLabel.text = [NSString stringWithFormat:@"at %@", vendorName];
    [self.stampVendorLabel sizeToFit];
    self.hidden = NO;
    [self layoutSubviews];
    self.alpha = 1.0;
    self.hidden = NO;
    self.center = CGPointMake(self.superview.center.x, self.superview.center.y + 120);
    [UIView animateWithDuration:5 animations:^{
        self.alpha = 0;
        self.center = CGPointMake(self.center.x, self.superview.center.y - 120);
    } completion:^(BOOL finished){
        self.hidden = YES;
    }];
}

- (void)layoutSubsubviews:(UIView *)view {
    CGFloat subviewWidth = 0;
    for (UIView *subview in view.subviews) {
        if (subview.hidden) {
            continue;
        }
        subviewWidth += subview.frame.size.width;
    }
    CGFloat currentX = (view.frame.size.width - subviewWidth) / 2;
    for (UIView *subview in view.subviews) {
        if (subview.hidden) {
            continue;
        }
        subview.center = CGPointMake(currentX + subview.frame.size.width / 2, subview.center.y);
        currentX += subview.frame.size.width;
    }
}

- (void)layoutSubviews {
    CGFloat subviewHeight = 0;
    for (UIView *subview in self.subviews) {
        if (subview.hidden) {
            continue;
        }
        subviewHeight += subview.frame.size.height;
    }
    CGFloat currentY = (self.frame.size.height - subviewHeight) / 2;
    for (UIView *subview in self.subviews) {
        if (subview.hidden) {
            continue;
        }
        subview.center = CGPointMake(subview.center.x, currentY + subview.frame.size.height / 2);
        [self layoutSubsubviews:subview];
        currentY += subview.frame.size.height;
    }
}

@end
