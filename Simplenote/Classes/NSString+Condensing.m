#import "NSString+Condensing.h"

@implementation NSString (Condensing)

- (NSString *)stringByCondensingSet:(NSCharacterSet *)set
{
	NSString *piece;
	NSMutableString *condensed = [NSMutableString stringWithCapacity:[self length]];
	NSScanner *scanner = [NSScanner scannerWithString:self];
	[scanner setCharactersToBeSkipped:set];
	
	BOOL needWhitespace = NO;
	
	while (![scanner isAtEnd])
	{
		piece = nil;
		[scanner scanUpToCharactersFromSet:set intoString:&piece];
		
		if (piece)
		{
			if (needWhitespace) [condensed appendString:@" "];
			[condensed appendString:piece];
			needWhitespace = YES;
		}
	}
	
	return condensed;
}

- (void)generatePreviewStrings:(void (^)(NSString *titlePreview, NSString *contentPreview))block {
    
    NSString *aString = [NSString stringWithString:self];
    NSString *titlePreview;
    NSString *contentPreview;
    
//    if (aString.length > 500)
//        aString = [aString substringToIndex:500];
    
	NSString *contentTest = [aString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	NSRange firstNewline = [contentTest rangeOfString: @"\n"];
	if (firstNewline.location == NSNotFound) {
		titlePreview = contentTest;
		contentPreview = nil;
	} else {
		titlePreview = [contentTest substringToIndex:firstNewline.location];
		contentPreview = [[contentTest substringFromIndex: firstNewline.location+1] stringByReplacingOccurrencesOfString:@"\n\n" withString:@" \n"];
		
		// Remove leading newline if applicable
		NSRange nextNewline = [contentPreview rangeOfString: @"\n"];
		if (nextNewline.location == 0)
			contentPreview = [contentPreview substringFromIndex:1];
	}

    
    // Remove Markdown #'s
    if ([titlePreview hasPrefix:@"#"]) {
        NSRange cutRange = [titlePreview rangeOfString:@"# "];
        if (cutRange.location != NSNotFound)
            titlePreview = [titlePreview substringFromIndex:cutRange.location + cutRange.length];
    }
    

    if (contentPreview)
        
        block(titlePreview, [NSString stringWithFormat:@"%@\n%@", titlePreview, contentPreview]);
    
    else
        
        block(titlePreview, titlePreview);
}

@end
