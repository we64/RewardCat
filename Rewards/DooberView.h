//
//  DooberView.h
//  RewardCat
//
//  Created by Chang Liu on 2013-01-26.
//
//

#import <UIKit/UIKit.h>

@interface DooberView : UIView

@property (nonatomic, retain) IBOutlet UIView *stampView;
@property (nonatomic, retain) IBOutlet UIView *coinView;
@property (nonatomic, retain) IBOutlet UILabel *stampLabel;
@property (nonatomic, retain) IBOutlet UILabel *coinLabel;
@property (nonatomic, retain) IBOutlet UILabel *stampVendorLabel;

- (void)showWithStamp:(int)stamp coin:(int)coin vendorName:(NSString *)vendorName;

@end
