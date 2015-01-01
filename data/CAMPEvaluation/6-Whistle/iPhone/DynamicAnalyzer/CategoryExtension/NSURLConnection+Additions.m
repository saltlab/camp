
#import "NSURLConnection+Additions.h"
#import <objc/runtime.h>
#import "OutputComponent.h"


// =======================================
// = Implementation for NSURLConnection+Additions =
// =======================================
@implementation NSURLConnection (additions)

+ (void)load {

//    if (self == [NSURLConnection class]) {
//        
//        Method originalMethod =
//        class_getInstanceMethod(self, @selector(initWithRequest:delegate:));
//        Method replacedMethod =
//        class_getInstanceMethod(self, @selector(swizzled_initWithRequest:delegate:));
//        method_exchangeImplementations(originalMethod, replacedMethod);
//        
//        originalMethod =
//        class_getInstanceMethod(self, @selector(initWithRequest:delegate:startImmediately:));
//        replacedMethod =
//        class_getInstanceMethod(self, @selector(swizzled_initWithRequest:delegate:startImmediately:));
//        method_exchangeImplementations(originalMethod, replacedMethod);
//
//	}
}

- (id)swizzled_initWithRequest:(NSURLRequest *)request delegate:(id)delegate
{
    [[OutputComponent sharedOutput] identifyRequest:request];
    return [self swizzled_initWithRequest:request delegate:delegate];
}

- (id)swizzled_initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately
{
    [[OutputComponent sharedOutput] identifyRequest:request];
    return [self swizzled_initWithRequest:request delegate:delegate startImmediately:startImmediately];
}

@end