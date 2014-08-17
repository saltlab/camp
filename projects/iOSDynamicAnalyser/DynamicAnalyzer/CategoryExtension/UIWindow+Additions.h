// =======================================
// = Interface for UIWindow+Additions =
// =======================================
@interface UIWindow (additions)

+ (void)load;
- (void)swizzled_sendEvent:(UIEvent *)event;

@end
