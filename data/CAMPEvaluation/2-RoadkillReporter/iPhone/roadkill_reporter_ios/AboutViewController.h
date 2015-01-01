#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIView *tutorialView;

@end
