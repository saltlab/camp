// =======================================
// = Interface for UINavigationController+Additions =
// =======================================
@interface UINavigationController (additions)

+ (void)load;
- (void)swizzled_navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
