//
//  NSString+Search.m
//  Simplenote
//
//  Created by Tom Witkin on 8/28/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "NSString+Search.h"



@implementation NSString (Search)

- (NSArray<NSValue *> *)wordRangesFilteredWithBlock:(BOOL (^)(NSString *))filterBlock
{
	CFStringTokenizerRef tokenRef = CFStringTokenizerCreate(NULL,
															(CFStringRef)self,
															CFRangeMake(0, self.length),
															kCFStringTokenizerUnitWordBoundary,
															NULL);
	
	CFStringTokenizerTokenType tokenType;

	NSMutableArray *wordBoxes = [NSMutableArray array];
	const unichar *src = (unichar*)[self cStringUsingEncoding:NSUTF16StringEncoding];
	NSString* word;
    CFRange wordRange;
	NSRange tempRange;
	
	// Proceed
	while ((tokenType = CFStringTokenizerAdvanceToNextToken(tokenRef)) != kCFStringTokenizerTokenNone)
	{
		wordRange = CFStringTokenizerGetCurrentTokenRange(tokenRef);
		tempRange = NSMakeRange(wordRange.location, wordRange.length);
		
		word = [NSString stringWithCharacters:(src + wordRange.location) length:(wordRange.length)];
		if (word == nil) {
			continue;
        }

        if (filterBlock(word)) {
            [wordBoxes addObject:[NSValue valueWithRange:tempRange]];
        }
	}
    
	CFRelease(tokenRef);
    
    return wordBoxes;
}

- (NSArray<NSValue *> *)rangesForTerms:(NSArray<NSString *> *)terms
{
    return [self wordRangesFilteredWithBlock:^BOOL(NSString *word) {
        for (NSString *term in terms) {
            if ([word rangeOfString:term
                            options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound) {
                return YES;
            }
        }
        return NO;
    }];
}


@end
