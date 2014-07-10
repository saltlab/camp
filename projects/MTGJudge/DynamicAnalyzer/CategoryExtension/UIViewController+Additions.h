// =======================================
// = Interface for UIViewController+Additions =
// =======================================
@interface UIViewController (additions)

+ (void)load;
- (void)swizzled_viewDidAppear:(BOOL)animated;

@end
