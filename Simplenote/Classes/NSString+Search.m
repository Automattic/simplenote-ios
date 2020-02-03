//
//  NSString+Search.m
//  Simplenote
//
//  Created by Tom Witkin on 8/28/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "NSString+Search.h"



@implementation NSString (Search)

- (NSArray *)constructRangesForWords {
    
    
	CFStringTokenizerRef tokenRef = CFStringTokenizerCreate(NULL,
															(CFStringRef)self,
															CFRangeMake(0, self.length),
															kCFStringTokenizerUnitWordBoundary,
															NULL);
	
	CFStringTokenizerTokenType tokenType;
    
	// Helpers: Alloc just once (way faster performance!)
	NSMutableArray *wordBoxes = [NSMutableArray arrayWithCapacity:self.length/3];
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
		
        [wordBoxes addObject:@{
			@"word"	: word,
			@"range": [NSValue valueWithRange:tempRange]
		}];
	}
    
	CFRelease(tokenRef);
    
    return wordBoxes;
    
}

- (NSArray<NSValue *> *)rangesForTerms:(NSString *)terms
{
	NSMutableArray *rangesFound = [NSMutableArray arrayWithCapacity:5];
    
	NSArray *termsArray = [terms componentsSeparatedByString:@" "];
	NSArray* wordRanges = [self constructRangesForWords];
	
	for (NSDictionary *wordDict in wordRanges) {
		for (NSString *term in termsArray) {
			if ([wordDict[@"word"] rangeOfString:term
                                         options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch].location != NSNotFound)
				[rangesFound addObject: wordDict[@"range"]];
		}
	}
	return rangesFound;
}


@end
