#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "UIView+UIView_Faster.h"
#import <MessageUI/MFMailComposeViewController.h>

NSString *baseUrl = @"http://roadkill-reporter.herokuapp.com/";
NSString *get = @"get";
NSString *post = @"post";
NSString *helloWorldPath = @"helloworld";
NSString *newIdPath = @"newid";
NSString *reportPath = @"report/%f/%f/%f/%d/%@/%@";

NSString *kUserid = @"userid";

bool locationFound = NO;

@interface ViewController ()

@end

@implementation ViewController


#pragma mark - UIVIewControllerDelegate methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self createSelf];
  }
  return self;
}

- (void) createSelf {
  self.title = NSLocalizedString(@"Report", @"Report");
  self.tabBarItem.image = [UIImage imageNamed:@"report"];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  _locationManager = [[CLLocationManager alloc] init];
  _locationManager.distanceFilter = kCLDistanceFilterNone;
  _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  _locationManager.delegate = self;
  [_locationManager startUpdatingLocation];
  
  _webData = [[NSMutableData alloc] init];
  
  [self wakeUpServer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - Server Interaction methods
- (IBAction)reportRoadkill:(id)sender {
  
  if (sender == _reportButton) {
    if (locationFound)
      [self showConfirmAlert];
    else
      [self showNoLocationAlert];
  }
}

- (void)showNoLocationAlert {
  UIAlertView *noLocationAlert = [[UIAlertView alloc] init];
  noLocationAlert.title = @"Location Unknown";
  noLocationAlert.message = @"Sorry, we can't seem to find your location.\nPlease allow Roadkill Reporter to access your location and try again.";
  [noLocationAlert addButtonWithTitle:@"Ok"];
  [noLocationAlert show];
}

- (void)showConfirmAlert {
  _confirmDialog = [[UIAlertView alloc] init];
	[_confirmDialog setTitle:@"Confirm Roadkill"];
	[_confirmDialog setMessage:@"There's a dead raccoon right here?"];
	[_confirmDialog setDelegate:self];
	[_confirmDialog addButtonWithTitle:@"Yes"];
	[_confirmDialog addButtonWithTitle:@"No"];
	[_confirmDialog show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (alertView == _confirmDialog) {
    if (buttonIndex == 0) {
      [alertView dismissWithClickedButtonIndex:1 animated:YES];
      [self reportConfirmed];
    }
    else if (buttonIndex == 1) {
      
    }
  }
}

- (void)reportConfirmed {
  NSLog(@"reporting roadkill");
  
  NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserid];
  CLLocationAccuracy accuracy = [_locationManager.location horizontalAccuracy];
  
  NSString *url = [baseUrl stringByAppendingString:reportPath];
  url = [NSString stringWithFormat:url, _locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude, accuracy, 0, userId, @"none"];
  
  [self urlConnect:url method:post];
}

// Improves Roadkill Reporting Time if the Server is Sleeping
- (void)wakeUpServer {
  NSLog(@"waking up server");
  NSString *url = [baseUrl stringByAppendingString:helloWorldPath];
  [self urlConnect:url method:get];
}

- (void)requestUserId {
  NSLog(@"requesting new userid");
  NSString *url = [baseUrl stringByAppendingString:newIdPath];
  [self urlConnect:url method:get];
}

- (void)urlConnect:(NSString *)url method:(NSString *)method {
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  
  NSLog(@"connectingto:%@",url);
  
  NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
  [req setHTTPMethod:method];
  
  (void) [[NSURLConnection alloc] initWithRequest:req delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [_webData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
  [_webData appendData:d];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                              message:[error localizedDescription]
                             delegate:nil
                    cancelButtonTitle:NSLocalizedString(@"OK", @"")
                    otherButtonTitles:nil] show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  
  NSString *responseText = [[NSString alloc] initWithData:_webData encoding:NSUTF8StringEncoding];
  responseText = [responseText substringFromIndex:21];
  NSError *myError = nil;
  NSData *stringData = [responseText dataUsingEncoding:NSUTF8StringEncoding];
  
  NSDictionary *res = [NSJSONSerialization JSONObjectWithData:stringData options:NSJSONReadingMutableLeaves error:&myError];
  NSString *status = [res objectForKey:@"status"];
  
  if ([status isEqualToString:@"Reported"]) {
    
    NSString *message = @"Your report was saved successfully.\nThanks!!";
    
    [[[UIAlertView alloc] initWithTitle:status message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
  }
  else if ([status isEqualToString:@"UUID"]) {
    NSString *newUserId = [res objectForKey:@"uuid"];
    if (newUserId) {
      NSLog(@"newuserid:%@",newUserId);
      [[NSUserDefaults standardUserDefaults] setObject:newUserId forKey:kUserid];
      [[NSUserDefaults standardUserDefaults] synchronize];
      //welcome new user
      [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome!", @"")
                                  message:NSLocalizedString(@"Thank you for helping with our research, your contributions will be greatly appreciated.\nIf you aren't sure this works, see\nAbout -> How to Use", @"")
                                 delegate:nil
                        cancelButtonTitle:NSLocalizedString(@"OK", @"")
                        otherButtonTitles:nil] show];
    }
    else {
      [self requestUserId];
    }
  }
  else {
    if ([@"world" isEqualToString:[res objectForKey:@"hello"]]) {
      NSLog(@"server is awake");
      NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserid];
      if (userId) {
        //do nothing...
      }
      else {
        NSLog(@"no userid found");
        [self requestUserId];
      }
    } else {
      [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Something's not right...", @"")
                                  message:NSLocalizedString(@"Please make sure you're logged in if you're using a public wifi hotspot and try again.", @"")
                                 delegate:nil
                        cancelButtonTitle:NSLocalizedString(@"OK", @"")
                        otherButtonTitles:nil] show];
    }
  }
}

#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  locationFound = YES;
}

//#pragma mark - Tell User about Roadkill Reporter
//- (IBAction)aboutRoadkillReporter:(id)sender {
//  _aboutButton.enabled = NO;
//  
//  NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AboutView" owner:self options:nil];
//  AboutView *aboutView = (AboutView *)[nib objectAtIndex:0];
//  aboutView.delegate = self;
//
//  aboutView.frame = self.view.bounds;
//  aboutView.topEdge = self.view.bottomEdge;
//  
//  [self.view addSubview:aboutView];
//  
//  [UIView animateWithDuration:0.5 animations:^(void) {
//    aboutView.topEdge = self.view.topEdge;
//  }];
//}
//
//
//#pragma mark - PopoverViewDelegate Protocol methods
//- (void) popoverActionConfirmed:(UIView *)popover {
//  _aboutButton.enabled = YES;
//  
//  NSArray *to = [[NSArray alloc] initWithObjects:@"roadkill.reporter.help@gmail.com", nil];
//  NSString *subject = @"Contact from Roadkill Reporter iOS App";
//  
//  MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
//  controller.mailComposeDelegate = self;
//  [controller setToRecipients:to];
//  [controller setSubject:subject];
//  if (controller) [self presentViewController:controller animated:YES completion:nil];;
//}
//
//- (void)mailComposeController:(MFMailComposeViewController*)controller
//          didFinishWithResult:(MFMailComposeResult)result
//                        error:(NSError*)error; {
//  if (result == MFMailComposeResultSent) {
//    NSLog(@"sent");
//  }
//  [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void) popoverActionCanceled:(UIView *)popover {
//  _aboutButton.enabled = YES;
//  
//  UIView *theView = (UIView *)popover;
//  
//  [UIView animateWithDuration:0.5 animations:^(void) {
//    theView.topEdge = self.view.bottomEdge;
//  } completion:^(BOOL finished) {
//    [popover removeFromSuperview];
//  }];
//}
//
//- (void) popoverDismissMe:(UIView *)popover {
//  _aboutButton.enabled = YES;
//  
//  UIView *theView = (UIView *)popover;
//  
//  [UIView animateWithDuration:0.5 animations:^(void) {
//    theView.topEdge = self.view.bottomEdge;
//  } completion:^(BOOL finished) {
//    [popover removeFromSuperview];
//  }];
//}

@end
