#import <UIKit/UIKit.h>

@interface UIView (UIView_Faster)

@property CGFloat leftEdge;
@property CGFloat rightEdge;
@property CGFloat topEdge;
@property CGFloat bottomEdge;

- (void) setLeftEdge:(CGFloat)leftEdge;
- (void) setRightEdge:(CGFloat)rightEdge;
- (void) setTopEdge:(CGFloat)topEdge;
- (void) setBottomEdge:(CGFloat)bottomEdge;

@property CGFloat origin_x;
@property CGFloat origin_y;
@property CGFloat height;
@property CGFloat width;

- (void) setOrigin_x:(CGFloat)origin_x;
- (void) setOrigin_y:(CGFloat)origin_y;
- (void) setHeight:(CGFloat)height;
- (void) setWidth:(CGFloat)width;

@property CGPoint origin;
@property CGPoint bottom_left;
@property CGPoint top_right;
@property CGPoint bottom_right;

- (void) setOrigin:(CGPoint)origin;
- (void) setBottom_left:(CGPoint)bottom_left;
- (void) setTop_right:(CGPoint)top_right;
- (void) setBottom_right:(CGPoint)bottom_right;

@end
