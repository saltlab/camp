// =======================================
// = Interface for NSURLRequest+Additions =
// =======================================
@interface NSJSONSerialization (additions)

+ (void)load;
+ (id)swizzled_JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;

@end
