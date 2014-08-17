
#import "UIWindow+Additions.h"
#import <objc/runtime.h>
#import "DCIntrospect.h"

// =======================================
// = Implementation for UIWindow+Additions =
// =======================================
@implementation UIWindow (additions)

+ (void)load {
    if (self == [UIWindow class]) {
        
        Method originalMethod = 
			class_getInstanceMethod(self, @selector(sendEvent:));
        Method replacedMethod = 
			class_getInstanceMethod(self, @selector(swizzled_sendEvent:));
        method_exchangeImplementations(originalMethod, replacedMethod);
    
	}
}

- (void)swizzled_sendEvent:(UIEvent *)event
{
    NSLog(@"%@", event);
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    NSLog(@"%@", touch.view);
    
    
    DCIntrospect *dcIntrospect = [[DCIntrospect alloc] init];
    [dcIntrospect logPropertiesForObject:touch.view];
    
    
    [self swizzled_sendEvent:event];
}

@end