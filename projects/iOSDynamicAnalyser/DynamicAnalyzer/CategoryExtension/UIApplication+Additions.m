
#import "UIApplication+Additions.h"
#import <objc/runtime.h>
#import "DCIntrospect.h"
#import "OutputComponent.h"
#include <dlfcn.h>

//#import <foundation foundation.h="">
//#import <mach-o nlist.h="">


// =======================================
// = Implementation for UIApplication+Additions =
// =======================================
@implementation UIApplication (additions)


//typedef int (*ObjCLogProc)(BOOL, const char *, const char *, SEL);
//typedef void (*logObjcMessageSends_t)(ObjCLogProc logProc);
//logObjcMessageSends_t logObjcMessageSends = 0;
//
//int main (int argc, const char * argv[]) {
//    logObjcMessageSends = dlsym(RTLD_DEFAULT, "logObjcMessageSends");
//}

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