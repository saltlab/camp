#import "AboutViewController.h"
#import "UIView+UIView_Faster.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      [self createSelf];
    }
    return self;
}

- (void)createSelf {
  self.title = NSLocalizedString(@"About", @"About");
  self.tabBarItem.image = [UIImage imageNamed:@"about"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tutorial:(id)sender {
  if (!self.tutorialView) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TutorialView" owner:self options:nil];
    self.tutorialView = (UIView *)[nib objectAtIndex:0];
    self.tutorialView.frame = self.view.frame;
    //remove height taken up by navigation bar
    self.tutorialView.height -= 44;
    //start offscreen
    self.tutorialView.topEdge = self.view.bottomEdge;
    [self.view addSubview:self.tutorialView];
  }
  
  if (self.tutorialView.topEdge == self.view.bottomEdge) {
    //animate onscreen
    [UIView animateWithDuration:0.5 animations:^(void) {
      self.tutorialView.topEdge = self.view.topEdge+44;
    }];
  } else {
    //animate offscreen
    [UIView animateWithDuration:0.5 animations:^(void) {
      self.tutorialView.topEdge = self.view.bottomEdge;
    }];
  }
}

- (IBAction)getHelp:(id)sender {
  NSArray *to = [[NSArray alloc] initWithObjects:@"roadkill.reporter.help@gmail.com", nil];
  NSString *subject = @"Contact from Roadkill Reporter iOS App";
  
  MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
  controller.mailComposeDelegate = self;
  [controller setToRecipients:to];
  [controller setSubject:subject];
  if (controller) [self presentViewController:controller animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error; {
  if (result == MFMailComposeResultSent) {
    NSLog(@"sent");
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
