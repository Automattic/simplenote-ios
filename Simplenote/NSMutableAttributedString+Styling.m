//
//  NSMutableAttributedString+TruncateToWidth.m
//  Simplenote
//
//  Created by Rainieri Ventura on 4/5/12.
//  Copyright (c) 2012 Simperium. All rights reserved.
//

#import "NSMutableAttributedString+Styling.h"
#import "Simplenote-Swift.h"
#import "SPTextView.h"

@implementation NSMutableAttributedString (Styling)

const int RegexExpectedMatchGroups  = 3;
const int RegexGroupIndexPrefix     = 1;
const int RegexGroupIndexContent    = 2;

// Replaces checklist markdown syntax with SPTextAttachment images in an attributed string
- (void)addChecklistAttachmentsForColor: (UIColor *)color  {

    if (self.length == 0) {
        return;
    }
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:CheckListRegExPattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    
    // Work with a copy of the NSString value so we can calculate the correct indices
    NSString *noteString = self.string.copy;
    NSArray *matches = [regex matchesInString:noteString options:0 range:[noteString rangeOfString:noteString]];
    
    if (matches.count == 0) {
        return;
    }
    
    int positionAdjustment = 0;
    CGFloat fontSize = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize + 4;
    for (NSTextCheckingResult *match in matches) {
        if ([match numberOfRanges] < RegexExpectedMatchGroups) {
            continue;
        }
        NSRange prefixRange = [match rangeAtIndex:RegexGroupIndexPrefix];
        NSRange checkboxRange = [match rangeAtIndex:RegexGroupIndexContent];
        
        NSString *markdownTag = [noteString substringWithRange:match.range];
        BOOL isChecked = [markdownTag localizedCaseInsensitiveContainsString:@"x"];
        
        SPTextAttachment *attachment = [[SPTextAttachment alloc] initWithColor:color];
        [attachment setIsChecked: isChecked];
        
        attachment.bounds = CGRectMake(0, -4.5, fontSize, fontSize);
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSRange adjustedRange = NSMakeRange(checkboxRange.location - positionAdjustment, checkboxRange.length);
        [self replaceCharactersInRange:adjustedRange withAttributedString:attachmentString];
        
        positionAdjustment += markdownTag.length - 1 - prefixRange.length;
    }
}

@end
