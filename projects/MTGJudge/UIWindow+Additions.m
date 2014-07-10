
#import "UIViewController+Additions.h"
#import <objc/runtime.h>

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
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"[%@ viewDidAppear]", NSStringFromClass(self.class));
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self swizzled_viewDidAppear:animated];
}

@end