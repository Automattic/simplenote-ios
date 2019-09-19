//
//  NSTextStorage+Highlight.m
//  Simplenote
//
//  Created by Tom Witkin on 8/28/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "NSTextStorage+Highlight.h"
#import "NSString+Search.h"

@implementation NSTextStorage (Highlight)

- (void)applyColor:(UIColor *)color toSubstringMatchingKeywords:(NSString *)keywords {
    NSArray* ranges = [self.string rangesForTerms:keywords];
    [self applyColorAttribute:color forRanges:ranges];
}

- (void)applyColorAttribute:(id)color forRanges:(NSArray *)wordRanges {
    
    if (!color) {
        return;
    }
    
    [self beginEditing];

    NSUInteger maxLength = self.string.length;
    
    for (NSValue *rangeValue in wordRanges) {
        
        // Out of Range Failsafe
        NSRange range = rangeValue.rangeValue;
        if (range.location + range.length >= maxLength) {
            continue;
        }
        
        // Maintain current Font
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithDictionary:[self attributesAtIndex:range.location effectiveRange:nil]];
        
        [attributes setObject:color forKey:NSForegroundColorAttributeName];
        
        [self setAttributes:attributes range:rangeValue.rangeValue];
    }
    
    [self endEditing];
}

- (void)applyAttributes:(NSDictionary *)attributes matchingStrings:(NSArray *)strings characterLimit:(NSInteger)characterLimit {
    
    
    NSString *content = self.string;
    
    [self beginEditing];
    
    for (NSString *matchString in strings) {
        
        // find all occurances of the matching string
        
        NSUInteger count = 0, length = MIN([content length], characterLimit);
        NSRange range = NSMakeRange(0, length);
        while(range.location != NSNotFound)
        {
            range = [content rangeOfString:matchString options:NSCaseInsensitiveSearch range:range];
            if(range.location != NSNotFound) {
                
                [self setAttributes:attributes range:range];
                
                range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                count++;
            }
        }
    }
    
    [self endEditing];
}


@end
