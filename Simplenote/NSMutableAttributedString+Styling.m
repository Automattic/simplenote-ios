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
        NSString *markdownTag = [noteString substringWithRange:match.range];
        BOOL isChecked = [markdownTag containsString:@"x"];
        
        SPTextAttachment *attachment = [[SPTextAttachment alloc] initWithColor:color];
        [attachment setIsChecked: isChecked];
        
        attachment.bounds = CGRectMake(0, -4.5, fontSize, fontSize);
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSRange adjustedRange = NSMakeRange(match.range.location - positionAdjustment, match.range.length);
        [self replaceCharactersInRange:adjustedRange withAttributedString:attachmentString];
        
        positionAdjustment += markdownTag.length - 1;
    }
}

@end
