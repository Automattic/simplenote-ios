
@interface NSString (Metadata)

// Removes pin and tags
- (NSArray *)stringArray;
// Search for a complete word. Does not match substrings of words. Requires fullWord be present
// and no surrounding alphanumeric characters.
- (BOOL)containsEmailAddress;

@end
