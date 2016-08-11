#import "NSString+Metadata.h"

@implementation NSString (Metadata)

- (NSString *)stringByStrippingMetadata
{
	NSString *stripped = [self substringFromIndex: ([self hasPrefix:@"!"] ? 1 : 0)];
	
	if ([stripped hasPrefix:@"#"]) {
		// The last tag is always followed by two spaces
		NSRange endOfTags = [stripped rangeOfString: @"  "];
		
		if (endOfTags.location == NSNotFound)
			return stripped;
		
		// Strip!
		stripped = [stripped substringFromIndex: endOfTags.location + endOfTags.length];
	}

	return stripped;
}

- (NSString *)stringByExtractingMetadata
{
	NSString *extracted = @"";
	if ([self hasPrefix: @"!#"] || [self hasPrefix: @"#"]) {
		NSRange endOfTags = [self rangeOfString: @"  "];
		if (endOfTags.location == NSNotFound)
			return self;
		extracted = [self substringToIndex: endOfTags.location + endOfTags.length];
	} else if ([self hasPrefix: @"!"]) {
		extracted = @"!";
	}
	
	return extracted;
}

- (NSString *)stringByStrippingTag:(NSString *)tag
{
	// Replace " tagName" and "tagName" (handles tags at the beginning, end, and middle of list)
	NSArray *tagArray = [self componentsSeparatedByString:@" "];
	NSMutableArray *tagArrayCopy = [tagArray mutableCopy];
	for (NSString *tagStr in tagArray) {
		if ([tagStr caseInsensitiveCompare: tag] == NSOrderedSame)
			[tagArrayCopy removeObject:tagStr];
	}

	return [tagArrayCopy componentsJoinedByString:@" "];
}

- (NSArray *)stringArray {
	NSMutableArray *list = [NSMutableArray arrayWithArray: [self componentsSeparatedByString:@" "]];
	NSMutableArray *discardedItems = [NSMutableArray array];
	NSString *str;
	
	for (str in list) {
		if ([str length] == 0)
			[discardedItems addObject:str];
	}
	
	[list removeObjectsInArray:discardedItems];

	return list;
}


- (BOOL)containsWholeWord:(NSString *)fullWord {
    NSRange result = [self rangeOfString:fullWord];
    if (result.length > 0) {
        if (result.location > 0 && [[NSCharacterSet alphanumericCharacterSet] characterIsMember:[self characterAtIndex:result.location - 1]]) {
			// Preceding character is alphanumeric
			return NO;
        }
        if (result.location + result.length < [self length] && [[NSCharacterSet alphanumericCharacterSet] characterIsMember:[self characterAtIndex:result.location + result.length]]) {
			// Trailing character is alphanumeric
			return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)isProbablyEmailAddress
{
	return [self rangeOfString:@"@"].location != NSNotFound && [self rangeOfString:@"."].location != NSNotFound;	
}

- (BOOL)containsEmailAddress {
    NSString *regEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    return [predicate evaluateWithObject:self];
}

- (NSString *)urlEncodeString
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

@end
