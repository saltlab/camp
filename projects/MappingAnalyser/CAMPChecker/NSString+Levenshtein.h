// =======================================
// = Interface for NSString+Levenshtein =
// =======================================

@interface NSString(Levenshtein)

// calculate the smallest distance between all words in stringA and stringB
- (float) compareWithString: (NSString *) stringB;

// calculate the distance between two string treating them each as a
// single word
- (float) compareWithWord: (NSString *) stringB;

// return the minimum of a, b and c
- (int) smallestOf: (int) a andOf: (int) b andOf: (int) c;

- (NSUInteger)levenshteinDistanceToString:(NSString *)string;

@end