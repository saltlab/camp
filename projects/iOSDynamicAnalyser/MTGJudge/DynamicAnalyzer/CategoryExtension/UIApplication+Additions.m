
#import "UIApplication+Additions.h"
#import <objc/runtime.h>
#import "DCIntrospect.h"
#import "OutputComponent.h"

// =======================================
// = Implementation for UIApplication+Additions =
// =======================================
@implementation UIApplication (additions)

+ (void)load {
    
    //Setup Method Calls
    [[OutputComponent sharedOutput] setup];
    
    if (self == [UIApplication class]) {
        
        Method originalMethod = 
			class_getInstanceMethod(self, @selector(sendEvent:));
        Method replacedMethod = 
			class_getInstanceMethod(self, @selector(swizzled_sendEvent:));
        method_exchangeImplementations(originalMethod, replacedMethod);
	}
}

- (void)swizzled_sendEvent:(UIEvent *)event
{
    [[OutputComponent sharedOutput] identifyEvent:event];
    [self swizzled_sendEvent:event];
}

@end