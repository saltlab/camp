
#import "NSString+Levenshtein.h"
#import <objc/runtime.h>

// =======================================
// = Implementation for NSString+Levenshtein =
// =======================================
@implementation NSString(Levenshtein)

// calculate the mean distance between all words in stringA and stringB
- (float) compareWithString: (NSString *) stringB
{
    float averageSmallestDistance = 0.0;
    float smallestDistance;
    float distance;
    
    NSMutableString * mStringA = [[NSMutableString alloc]  initWithString: self];
    NSMutableString * mStringB = [[NSMutableString alloc]  initWithString: stringB];
    
    
    // normalize
    [mStringA replaceOccurrencesOfString:@"\n"
                              withString: @" "
                                 options: NSLiteralSearch
                                   range: NSMakeRange(0, [mStringA  length])];
    
    [mStringB replaceOccurrencesOfString:@"\n"
                              withString: @" "
                                 options: NSLiteralSearch
                                   range: NSMakeRange(0, [mStringB  length])];
    
    NSArray * arrayA = [mStringA componentsSeparatedByString: @" "];
    NSArray * arrayB = [mStringB componentsSeparatedByString: @" "];
    
    NSEnumerator * emuA = [arrayA objectEnumerator];
    NSEnumerator * emuB;
    
    NSString * tokenA = NULL;
    NSString * tokenB = NULL;
    
    // O(n*m) but is there another way ?!?
    while ( tokenA = [emuA nextObject] ) {
        
        emuB = [arrayB objectEnumerator];
        smallestDistance = 99999999.0;
        
        while ( tokenB = [emuB nextObject] )
            if ( (distance = [tokenA compareWithWord: tokenB] ) &&  smallestDistance )
                smallestDistance = distance;
        
        averageSmallestDistance += smallestDistance;
        
    }
    
    return averageSmallestDistance / [arrayA count];
}


// calculate the distance between two string treating them eash as a
// single word
- (float) compareWithWord: (NSString *) stringB
{
    // normalize strings
    NSString * stringA = [NSString stringWithString: self];
    [stringA stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [stringB stringByTrimmingCharactersInSet:
     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    stringA = [stringA lowercaseString];
    stringB = [stringB lowercaseString];
    
    
    // Step 1
    int k, i, j, cost, * d, distance;
    
    int n = [stringA length];
    int m = [stringB length];
    
    if( n++ != 0 && m++ != 0 ) {
        
        d = malloc( sizeof(int) * m * n );
        
        // Step 2
        for( k = 0; k < n; k++)
            d[k] = k;
        
        for( k = 0; k < m; k++)
            d[ k * n ] = k;
        
        // Step 3 and 4
        for( i = 1; i < n; i++ )
            for( j = 1; j < m; j++ ) {
                
                // Step 5
                if( [stringA characterAtIndex: i-1] ==
                   [stringB characterAtIndex: j-1] )
                    cost = 0;
                else
                    cost = 1;
                
                // Step 6
                d[ j * n + i ] = [self smallestOf: d [ (j - 1) * n + i ] + 1
                                            andOf: d[ j * n + i - 1 ] +  1
                                            andOf: d[ (j - 1) * n + i -1 ] + cost ];
            }
        
        distance = d[ n * m - 1 ];
        
        free( d );
        
        return distance;
    }
    return 0.0;
}


// return the minimum of a, b and c
- (int) smallestOf: (int) a andOf: (int) b andOf: (int) c
{
    int min = a;
    if ( b < min )
        min = b;
    
    if( c < min )
        min = c;
    
    return min;
}


- (NSUInteger)levenshteinDistanceToString:(NSString *)string {
    NSUInteger sl = [self length];
    NSUInteger tl = [string length];
    NSUInteger *d = calloc(sizeof(*d), (sl+1) * (tl+1));
    
#define d(i, j) d[((j) * sl) + (i)]
    for (NSUInteger i = 0; i <= sl; i++) {
        d(i, 0) = i;
    }
    for (NSUInteger j = 0; j <= tl; j++) {
        d(0, j) = j;
    }
    for (NSUInteger j = 1; j <= tl; j++) {
        for (NSUInteger i = 1; i <= sl; i++) {
            if ([self characterAtIndex:i-1] == [string characterAtIndex:j-1]) {
                d(i, j) = d(i-1, j-1);
            } else {
                d(i, j) = MIN(d(i-1, j), MIN(d(i, j-1), d(i-1, j-1))) + 1;
            }
        }
    }
    
    NSUInteger r = d(sl, tl);
#undef d
    
    free(d);
    
    return r;
}

@end


