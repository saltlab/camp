// =======================================
// = Interface for UIApplication+Additions =
// =======================================
@interface UIApplication (additions)

+ (void)load;
- (void)swizzled_sendEvent:(UIEvent *)event;
- (BOOL)swizzled_openURL:(NSURL*)url;

@end
