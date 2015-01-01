// =======================================
// = Interface for AFHTTPClient+Additions =
// =======================================
#import "AFHTTPClient.h"

@interface AFHTTPClient (additions)

+ (void)load;
- (NSMutableURLRequest *)swizzled_requestWithMethod:(NSString *)method
                                               path:(NSString *)path
                                         parameters:(NSDictionary *)parameters;
@end
