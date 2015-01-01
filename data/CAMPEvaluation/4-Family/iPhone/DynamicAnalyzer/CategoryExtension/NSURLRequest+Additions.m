
#import "NSURLRequest+Additions.h"
#import <objc/runtime.h>
#import "OutputComponent.h"


// =======================================
// = Implementation for NSURLRequest+Additions =
// =======================================
@implementation NSURLRequest (additions)



+ (void)load {

    if (self == [NSURLRequest class]) {
        
        Method originalMethod = 
          class_getInstanceMethod(self, @selector(requestWithURL:cachePolicy:timeoutInterval:));
        Method replacedMethod = 
          class_getInstanceMethod(self, @selector(swizzled_requestWithURL:cachePolicy:timeoutInterval:));
        method_exchangeImplementations(originalMethod, replacedMethod);
	}
}

+ (id)swizzled_requestWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval
{
//   [[OutputComponent sharedOutput] identifyRequest:[self swizzled_requestWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval]];
//    
    return [self swizzled_requestWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
}


@end