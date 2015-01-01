// =======================================
// = Interface for NSObject+Additions =
// =======================================
@interface NSObject (additions)

+ (void)load;
- (IMP)swizzled_methodForSelector:(SEL)aSelector;

@end
