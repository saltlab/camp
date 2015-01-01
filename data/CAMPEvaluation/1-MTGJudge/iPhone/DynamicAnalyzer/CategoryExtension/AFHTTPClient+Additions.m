
#import "AFHTTPClient+Additions.h"
#import <objc/runtime.h>
#import "OutputComponent.h"


// =======================================
// = Implementation for AFHTTPClient+Additions =
// =======================================
@implementation AFHTTPClient (additions)



+ (void)load {

    if (self == [AFHTTPClient class]) {
        
        Method originalMethod =
        class_getInstanceMethod(self, @selector(requestWithMethod:path:parameters:));
        Method replacedMethod =
        class_getInstanceMethod(self, @selector(swizzled_requestWithMethod:path:parameters:));
        method_exchangeImplementations(originalMethod, replacedMethod);

	}
}

- (NSMutableURLRequest *)swizzled_requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    [[OutputComponent sharedOutput] identifyRequest:[self swizzled_requestWithMethod:method path:path parameters:parameters] method:method parameters:parameters];
    
    return [self swizzled_requestWithMethod:method path:path parameters:parameters];
}


@end