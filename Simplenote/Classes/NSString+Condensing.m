#import "NSString+Condensing.h"

@implementation NSString (Condensing)

- (void)generatePreviewStrings:(void (^)(NSString *titlePreview, NSString *bodyPreview))block
{
    NSString *trimmed = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // Remove Markdown #'s from the title
    NSRange cutRange = [trimmed rangeOfString:@"# "];
    if (cutRange.location == 0) {
        trimmed = [trimmed substringFromIndex:NSMaxRange(cutRange)];
    }

    // Do we even have more than one line?
	NSInteger locationForBody = [trimmed rangeOfString: @"\n"].location;

	if (locationForBody == NSNotFound) {
        block(trimmed, nil);
        return;
	}

    // Split Title / Body
    NSString *title = [trimmed substringToIndex:locationForBody];
    NSString *body = [[trimmed substringFromIndex:locationForBody] stringByReplacingNewlinesWithSpaces];

    block(title, body);
}

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
