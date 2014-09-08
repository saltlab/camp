
#import "NSObject+Additions.h"
#import <objc/runtime.h>


// =======================================
// = Implementation for NSObject+Additions =
// =======================================
@implementation NSObject (additions)



+ (void)load {

//    if (self == [NSObject class]) {
//        
//        Method originalMethod = 
//			class_getInstanceMethod(self, @selector(methodForSelector:));
//        Method replacedMethod = 
//			class_getInstanceMethod(self, @selector(swizzled_methodForSelector:));
//        method_exchangeImplementations(originalMethod, replacedMethod);
//	}
}

- (IMP)swizzled_methodForSelector:(SEL)aSelector
{
    //NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [self swizzled_methodForSelector:aSelector];
}



+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
    
    if ([self isSubclassOfClass:[UIEvent class]] ) {

    //NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(aSEL));
    }
//    if ([NSStringFromSelector(aSEL) hasPrefix:@"set"]) {
//        class_addMethod([self class], aSEL,
//                        (IMP)setPropertyIMP, "v@:@");
//    }
//    else {
//        class_addMethod([self class], aSEL,
//                        (IMP)propertyIMP, "@@:");
//    }
    return YES;
}


@end