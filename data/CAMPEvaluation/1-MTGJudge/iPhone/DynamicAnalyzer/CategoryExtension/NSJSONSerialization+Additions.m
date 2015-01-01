
#import "NSJSONSerialization+Additions.h"
#import <objc/runtime.h>


// =======================================
// = Implementation for NSJSONSerialization+Additions =
// =======================================
@implementation NSJSONSerialization (additions)



+ (void)load {

    if (self == [NSJSONSerialization class]) {
        
        Method originalMethod = 
			class_getInstanceMethod(self, @selector(JSONObjectWithData:options:error:));
        Method replacedMethod = 
			class_getInstanceMethod(self, @selector(swizzled_JSONObjectWithData:options:error:));
        method_exchangeImplementations(originalMethod, replacedMethod);
	}
}

+ (id)swizzled_JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;
{
    NSLog(@"Mona Mona %@", data);
    return [self swizzled_JSONObjectWithData:data options:opt error:error];
}


@end