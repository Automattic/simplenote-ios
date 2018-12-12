//
//  UITextView+Simplenote.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/25/15.
//  Copyright (c) 2015 Simperium. All rights reserved.
//

#import "UITextView+Simplenote.h"
#import "NSString+Bullets.h"



#pragma mark ====================================================================================
#pragma mark NSTextView (Simplenote)
#pragma mark ====================================================================================

@implementation UITextView (Simplenote)

- (BOOL)applyAutoBulletsWithReplacementText:(NSString *)replacementText replacementRange:(NSRange)replacementRange
{
    // ReplacementText must be a TAB or NewLine
    if (!replacementText.isNewlineString && !replacementText.isTabString) {
        return NO;
    }
    
    // Determine what kind of bullet we should insert
    NSString *rawString                 = self.text;
    NSRange lineRange                   = [rawString lineRangeForRange:replacementRange];
    NSString *lineString                = [rawString substringWithRange:lineRange];
    NSString *cleanLineString           = [lineString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *textAttachmentCode = @"\U0000fffc";
    NSArray *const bullets              = @[@"*", @"+", @"-", textAttachmentCode];
    NSString *stringToAppendToNewLine   = nil;
    
    for (NSString *bullet in bullets) {
        if ([cleanLineString hasPrefix:bullet]) {
            stringToAppendToNewLine = [bullet isEqualToString:textAttachmentCode] ? @"- [ ] " : bullet;
            break;
        }
    }
    
    // Stop right here... if there's no bullet!
    if (!stringToAppendToNewLine) {
        return NO;
    }
    
    NSUInteger bulletLength = stringToAppendToNewLine.length;
    
    NSInteger indexOfBullet             = [lineString rangeOfString:stringToAppendToNewLine].location;
    NSRange newSelectedRange            = self.selectedRange;
    NSString *insertionString           = nil;
    NSRange insertionRange              = lineRange;
    
    // Tab entered: Move the bullet along
    if (replacementText.isTabString) {
        // Proceed only if the user is entering Tab's right by the first one
        //  -   Something
        //     ^
        //
        NSInteger const IndentationIndexDelta = 2;

        if (replacementRange.location != lineRange.location + indexOfBullet + IndentationIndexDelta) {
            return NO;
        }
        
        insertionString                 = [replacementText stringByAppendingString:lineString];
        newSelectedRange.location       += replacementText.length;
        
    // Empty Line: Remove the bullet
    } else if (cleanLineString.length == 1) {
        insertionString                 = [NSString newLineString];
        newSelectedRange.location       -= lineRange.length - bulletLength;
        
    // Attempt to apply the bullet
    } else  {
        BOOL isApplyingChecklist = [lineString hasPrefix:textAttachmentCode];
        // Substring: [0 - Bullet]
        if (!isApplyingChecklist) {
            NSRange bulletPrefixRange       = NSMakeRange(0, [lineString rangeOfString:stringToAppendToNewLine].location + bulletLength);
            stringToAppendToNewLine         = [lineString substringWithRange:bulletPrefixRange];
        }
        
        // Do we need to append a whitespace?
        if (lineRange.length > indexOfBullet + bulletLength) {
            unichar bulletTrailing      = [lineString characterAtIndex:indexOfBullet + bulletLength];
            
            if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:bulletTrailing]) {
                NSString *trailing      = [NSString stringWithFormat:@"%c", bulletTrailing];
                stringToAppendToNewLine = [stringToAppendToNewLine stringByAppendingString:trailing];
            }
        }
        
        // Replacement + NewRange
        insertionString                 = [[NSString newLineString] stringByAppendingString:stringToAppendToNewLine];
        insertionRange                  = replacementRange;
        newSelectedRange.location       += isApplyingChecklist ? 3 : insertionString.length;
    }
    
    // Apply the Replacements
    NSTextStorage *storage = self.textStorage;
    [storage beginEditing];
    [storage replaceCharactersInRange:insertionRange withString:insertionString];
    [storage endEditing];
    
    // Update the Selected Range (If needed)
    [self setSelectedRange:newSelectedRange];
    
    // Signal that the text was changed!
    [self.delegate textViewDidChange:self];
    
    return YES;
}

- (NSRange)visibleTextRange
{
    CGRect bounds           = self.bounds;
    UITextPosition *start   = [self characterRangeAtPoint:bounds.origin].start;
    UITextPosition *end     = [self characterRangeAtPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))].end;
    
    return NSMakeRange([self offsetFromPosition:self.beginningOfDocument toPosition:start],
                       [self offsetFromPosition:start toPosition:end]);
}

@end
