//
//#import "UIViewController+Additions.h"
//#import <objc/runtime.h>
//#import "UIState.h"
//
//// =======================================
//// = Implementation for UIViewController+Additions =
//// =======================================
//@implementation UIViewController (additions)
//
//+ (void)load {
//    if (self == [UIViewController class]) {
//        
//        Method originalMethod = 
//			class_getInstanceMethod(self, @selector(viewDidAppear:));
//        Method replacedMethod = 
//			class_getInstanceMethod(self, @selector(swizzled_viewDidAppear:));
//        method_exchangeImplementations(originalMethod, replacedMethod);
//        
//	}
//}
//
//- (void)swizzled_viewDidAppear:(BOOL)animated
//{
//    //ignore if UINavigationController or UITabBarController
//    if ((self.class != UINavigationController.class) && (self.class != UITabBarController.class) && ![self isKindOfClass: UINavigationController.class] && ![self isKindOfClass: UITabBarController.class])
//    {
//        if ([self isVisible]) {
//            
//            [[NSUserDefaults standardUserDefaults] setValue:@"ViewControllerLoaded" forKey:@"DynamicAnalyser_isViewControllerLoaded"];
//            
//            UIState *thisState = [[UIState alloc] init];
//            thisState.className = [NSString stringWithFormat:@"%@",self.class];
//            thisState.title = self.title;
//            thisState.viewController = self;
//            [thisState setAllUIElementsForViewController:self];
//        }
//    }
//
//    [self swizzled_viewDidAppear:animated];
//}
//
//
//- (BOOL)isVisible {
//    
//    UIViewController *currentViewController = self.navigationController.visibleViewController;
//    if (currentViewController == self)
//        return YES;
//    return NO;
//        //return [self isViewLoaded] && self.view.window;
//}
//
//
//@end





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
        
        originalMethod =
        class_getInstanceMethod(self, @selector(dismissModalViewControllerAnimated:));
        replacedMethod =
        class_getInstanceMethod(self, @selector(icDismissModalViewControllerAnimated:));
        method_exchangeImplementations(originalMethod, replacedMethod);
        
        originalMethod =
        class_getInstanceMethod(self, @selector(presentModalViewController:animated:));
        replacedMethod =
        class_getInstanceMethod(self, @selector(icPresentModalViewController:animated:));
        method_exchangeImplementations(originalMethod, replacedMethod);
        
	}
}

- (void)swizzled_viewDidAppear:(BOOL)animated
{
    //ignore if UINavigationController
    if ((self.class != UINavigationController.class) && ![self isKindOfClass: UINavigationController.class])
    {
        //check if not UITabBarController
        if ((self.class != UITabBarController.class) && ![self isKindOfClass: UITabBarController.class])
        {
            if (!self.navigationController || (self.navigationController && [self isVisible])) {
                
                [[NSUserDefaults standardUserDefaults] setValue:@"ViewControllerLoaded" forKey:@"DynamicAnalyser_isViewControllerLoaded"];
                
                UIState *thisState = [[UIState alloc] init];
                thisState.className = [NSString stringWithFormat:@"%@",self.class];
                thisState.title = self.title;
                thisState.viewController = self;
                [thisState setAllUIElementsForViewController:self];
            }
        }
        //check if UITabBarController
        else {
            UITabBarController* someTabBarController = (UITabBarController*)self;
            UIViewController* selected = someTabBarController.selectedViewController;
            
            if ((selected.class != UINavigationController.class) && ![selected isKindOfClass: UINavigationController.class]) {
                
                [[NSUserDefaults standardUserDefaults] setValue:@"ViewControllerLoaded" forKey:@"DynamicAnalyser_isViewControllerLoaded"];
                
                UIState *thisState = [[UIState alloc] init];
                thisState.className = [NSString stringWithFormat:@"%@",selected.class];
                thisState.title = selected.title;
                thisState.viewController = selected;
                [thisState setAllUIElementsForViewController:selected];
            }
            
        }
    }
    
    [self swizzled_viewDidAppear:animated];
}


- (BOOL)isVisible {
    
    UIViewController *currentViewController = self.navigationController.visibleViewController;
    if (currentViewController == self)
        return YES;
    return NO;
    //return [self isViewLoaded] && self.view.window;
}



- (void)icDismissModalViewControllerAnimated:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IC_isDismissed"];
    // Call the original (now renamed) dismissModalViewControllerAnimated:
    [self icDismissModalViewControllerAnimated:animated];
}

- (void)icPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IC_isPresented"];
    // Call the original (now renamed) presentModalViewController:
    [self icPresentModalViewController:modalViewController animated:animated];
}

- (BOOL)isViewDismissed {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IC_isDismissed"]) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IC_isDismissed"];
		return TRUE;
	}
	return FALSE;
}

- (BOOL)isViewPresented {
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IC_isPresented"]) {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IC_isPresented"];
		return TRUE;
	}
	return FALSE;
}



@end