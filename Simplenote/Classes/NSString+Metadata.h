
@interface NSString (Metadata)

// Removes pin and tags
- (NSString *)stringByStrippingMetadata;
- (NSString *)stringByExtractingMetadata;
- (NSString *)stringByStrippingTag:(NSString *)tag;
- (NSArray *)stringArray;
// Search for a complete word. Does not match substrings of words. Requires fullWord be present
// and no surrounding alphanumeric characters.
- (BOOL)containsWholeWord:(NSString *)fullWord;
- (BOOL)isProbablyEmailAddress;
- (BOOL)containsEmailAddress;
- (NSString *)urlEncodeString;

@end
