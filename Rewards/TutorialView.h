//
//  TutorialView.h
//  RewardCat
//
//  Created by Chang Liu on 2013-02-23.
//
//

#import <UIKit/UIKit.h>

@interface TutorialView : UIView

@property (nonatomic, retain) IBOutlet UIButton *next;
@property (nonatomic, retain) IBOutlet UIButton *previous;
@property (nonatomic, retain) IBOutlet UIButton *finish;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *dots;
@property (nonatomic, retain) IBOutletCollection(UIView) NSArray *tutorialViews;
@property (nonatomic) int page;
@property (nonatomic) BOOL showFacebookPage;

- (IBAction)nextClicked;
- (IBAction)previousClicked;
- (IBAction)signInWithFacebook:(id)sender;

@end
