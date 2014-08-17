
#import "UIViewController+Additions.h"
#import <objc/runtime.h>
#import "UIState.h"

// =======================================
// = Implementation for UIViewController+Additions =
// =======================================
@implementation UIViewController (additions)

+ (void)load {
    if (self == [UIViewController class]) {
        
        Method originalMethod = 
			class_getInstanceMethod(self, @selector(viewDidAppear:));
        Method replacedMethod = 
			class_getInstanceMethod(self, @selector(swizzled_viewDidAppear:));
        method_exchangeImplementations(originalMethod, replacedMethod);
	}
}

- (void)swizzled_viewDidAppear:(BOOL)animated
{
    //ignore if UINavigationController or UITabBarController
    if ((self.class != UINavigationController.class) && (self.class != UITabBarController.class) && ![self isKindOfClass: UINavigationController.class] && ![self isKindOfClass: UITabBarController.class])
    {
        UIState *thisState = [[UIState alloc] init];
        thisState.className = [NSString stringWithFormat:@"%@",self.class];
        thisState.title = self.title;
        [thisState setAllUIElementsForViewController:self];
    }

    [self swizzled_viewDidAppear:animated];
}




@end