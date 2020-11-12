#import "NSString+Condensing.h"

@implementation NSString (Condensing)

- (NSString *)stringByReplacingNewlinesWithSpaces
{
    if (self.length == 0) {
        return self;
    }

    // Newlines: \n *AND* \r's!
    NSMutableArray *components = [[self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];

    // Note: The following nukes everything that tests true for `isEquals`: Every single empty string is gone!
    [components removeObject:@""];

    return [components componentsJoinedByString:@" "];
}

@end
