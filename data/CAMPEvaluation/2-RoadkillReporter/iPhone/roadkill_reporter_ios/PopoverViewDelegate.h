#import <Foundation/Foundation.h>

@protocol PopoverViewDelegate <NSObject>

@required
- (void) popoverActionConfirmed:(UIView *)theView;
- (void) popoverActionCanceled:(UIView *)theView;
- (void) popoverDismissMe:(UIView *)theView;

@end
