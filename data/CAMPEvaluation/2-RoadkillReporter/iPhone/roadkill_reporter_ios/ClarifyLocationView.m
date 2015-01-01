#import "ClarifyLocationView.h"

@implementation ClarifyLocationView

- (IBAction)confirmLocation:(id)sender {
  NSLog(@"location confirmed");
  [self.delegate popoverActionConfirmed:self];
}

- (IBAction)cancelLocation:(id)sender {
  NSLog(@"canceled map popover");
  [self.delegate popoverActionCanceled:self];
}

@end