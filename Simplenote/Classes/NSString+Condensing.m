#import "NSString+Condensing.h"

@implementation NSString (Condensing)

- (void)generatePreviewStrings:(void (^)(NSString *titlePreview, NSString *bodyPreview, NSString *contentPreview))block {
    
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
    

    if (contentPreview) {
        
        block(titlePreview, contentPreview, [NSString stringWithFormat:@"%@\n%@", titlePreview, contentPreview]);
    
    } else {
        
        block(titlePreview, nil, titlePreview);

    }
}

@end
