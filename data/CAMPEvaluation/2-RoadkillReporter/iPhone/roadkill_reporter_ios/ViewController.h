//
//  ViewController.h
//  roadkill_reporter_ios
//
//  Created by Caleb Gomer on 11/16/12.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PopoverViewDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *reportButton;
@property (strong, nonatomic) IBOutlet UIButton *aboutButton;
@property (strong, nonatomic) IBOutlet UILabel *accuracyLabel;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableData *webData;
@property (strong, nonatomic) UIAlertView *confirmDialog;


- (IBAction)reportRoadkill:(id)sender;

@end
