//
//  ProcessingView.m
//  RewardCat
//
//  Created by Chang Liu on 2013-01-26.
//
//

#import "ProcessingView.h"

@implementation ProcessingView

@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [imageView release], imageView = nil;
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
