// =======================================
// = Interface for NSURLRequest+Additions =
// =======================================
@interface NSURLRequest (additions)

+ (void)load;
+ (id)swizzled_requestWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;

@end
