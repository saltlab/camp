// =======================================
// = Interface for NSURLConnection+Additions =
// =======================================

@interface NSURLConnection (additions)

+ (void)load;
- (id)swizzled_initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately;
- (id)swizzled_initWithRequest:(NSURLRequest *)request delegate:(id)delegate;

@end
