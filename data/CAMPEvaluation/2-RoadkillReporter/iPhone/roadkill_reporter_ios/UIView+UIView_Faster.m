#import "UIView+UIView_Faster.h"

@implementation UIView (UIView_Faster)

- (CGFloat) leftEdge {
  return self.frame.origin.x;
}
- (CGFloat) rightEdge {
  return self.frame.origin.x + self.frame.size.width;
}
- (CGFloat) topEdge {
  return self.frame.origin.y;
}
- (CGFloat) bottomEdge {
  return self.frame.origin.y + self.frame.size.height;
}

- (void) setLeftEdge:(CGFloat)leftEdge {
  self.frame = CGRectMake(leftEdge, self.origin_y, self.width, self.height);
}
- (void) setRightEdge:(CGFloat)rightEdge {
  self.frame = CGRectMake(self.origin_x, self.origin_y, rightEdge-self.leftEdge, self.height);
}
- (void) setTopEdge:(CGFloat)topEdge {
  self.origin_y = topEdge;
}
- (void) setBottomEdge:(CGFloat)bottomEdge {
  self.frame = CGRectMake(self.origin_x, self.origin_y, self.width, bottomEdge - self.topEdge);
}

- (CGFloat) origin_x {
  return self.frame.origin.x;
}
- (CGFloat) origin_y {
  return self.frame.origin.y;
}
- (CGFloat) height {
  return self.frame.size.height;
}
- (CGFloat) width {
  return self.frame.size.width;
}

- (void) setOrigin_x:(CGFloat)origin_x {
  self.frame = CGRectMake(origin_x, self.origin_y, self.width, self.height);
}
- (void) setOrigin_y:(CGFloat)origin_y {
  self.frame = CGRectMake(self.origin_x, origin_y, self.width, self.height);
}
- (void) setHeight:(CGFloat)height {
  self.frame = CGRectMake(self.origin_x, self.origin_y, self.width, height);
}
- (void) setWidth:(CGFloat)width {
  self.frame = CGRectMake(self.origin_x, self.origin_y, width, self.height);
}

- (CGPoint) origin {
  return self.frame.origin;
}
- (CGPoint) bottom_left {
  return CGPointMake(self.origin_x, self.origin_y + self.height);
}
- (CGPoint) top_right {
  return CGPointMake(self.origin_x + self.width, self.origin_y);
}
- (CGPoint) bottom_right {
  return CGPointMake(self.origin_x + self.width, self.origin_y + self.height);
}

- (void) setOrigin:(CGPoint)origin {
  self.frame = CGRectMake(origin.x, origin.y, self.width, self.height);
}
- (void) setBottom_left:(CGPoint)bottom_left {
  self.frame = CGRectMake(bottom_left.x, self.origin_y, self.width, bottom_left.y - self.origin_y);
}
- (void) setTop_right:(CGPoint)top_right {
  self.frame = CGRectMake(self.origin_x, top_right.y, top_right.x - self.origin_x, self.height);
}
- (void) setBottom_right:(CGPoint)bottom_right {
  self.frame = CGRectMake(self.origin_x, self.origin_y, bottom_right.x - self.origin_x, bottom_right.y - self.origin_y);
}

@end
