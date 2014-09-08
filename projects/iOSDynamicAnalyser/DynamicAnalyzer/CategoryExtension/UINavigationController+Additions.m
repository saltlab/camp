
#import "UINavigationController+Additions.h"
#import <objc/runtime.h>
#import "UIState.h"

// =======================================
// = Implementation for UINavigationController+Additions =
// =======================================
@implementation UIControl (additions)

+ (void)load {
    if (self == [UINavigationController class]) {
        
        Method originalMethod = 
        class_getInstanceMethod(self, @selector(touchesEnded:withEvent:));
        Method replacedMethod = 
        class_getInstanceMethod(self, @selector(swizzled_navigationController:didShowViewController:animated:));
        method_exchangeImplementations(originalMethod, replacedMethod);
        
	}
}

- (void)swizzled_navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //ignore if UINavigationController or UITabBarController
    if ((self.class != UINavigationController.class) && (self.class != UITabBarController.class) && ![self isKindOfClass: UINavigationController.class] && ![self isKindOfClass: UITabBarController.class])
    {
        if ([self isVisible]) {
            
            UIState *thisState = [[UIState alloc] init];
            thisState.className = [NSString stringWithFormat:@"%@",self.class];
            thisState.title = self.title;
            [thisState setAllUIElementsForViewController:self];
        }
    }

    [self swizzled_navigationController:navigationController didShowViewController:viewController animated:animated];
}


- (BOOL)isVisible {
    
    UIViewController *currentViewController = self.navigationController.visibleViewController;
    if (currentViewController == self)
        return YES;
    return NO;
        //return [self isViewLoaded] && self.view.window;
}


@end