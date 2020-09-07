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

@end
