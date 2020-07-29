#import "NSString+Metadata.h"

@implementation NSString (Metadata)

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

- (BOOL)containsEmailAddress {
    NSString *regEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    return [predicate evaluateWithObject:self];
}

@end
