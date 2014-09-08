
#import "UIApplication+Additions.h"
#import <objc/runtime.h>
#import "DCIntrospect.h"
#import "OutputComponent.h"
#include <dlfcn.h>


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
    //instrumentObjcMessageSends(YES);
    [self swizzled_sendEvent:event];
    //instrumentObjcMessageSends(NO);
}

- (BOOL)swizzled_openURL:(NSURL*)url
{
    NSString *telString = [url absoluteString];
    if ([[url absoluteString] rangeOfString:@"tel:"].location == NSNotFound)
    //if ([telString rangeOfString:@"tel:"])
        [[OutputComponent sharedOutput] identifyCall:url];
    
    return [self swizzled_openURL:url];
}

//int	MyLogObjCMessageSend (BOOL	isClassMethod,
//                          const char *	objectsClass,
//                          const char *	implementingClass,
//                          SEL	selector)
//{
//    // Make the log entry -- Replace this function's code by anything you want
//    NSLog( @"That's me %c %s %s %s\n",
//          isClassMethod ? '+' : '-',
//          objectsClass,
//          implementingClass,
//          (char *) selector);
//    return 0;
//}


@end