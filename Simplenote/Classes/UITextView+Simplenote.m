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

const int ChecklistItemLength = 3;

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
    NSString *textAttachmentCode = @"\U0000fffc"; // Represents the glyph of an NSTextAttachment
    NSArray *const bullets              = @[@"*", @"+", @"-", @"•", textAttachmentCode];
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
    
    NSUInteger bulletLength             = stringToAppendToNewLine.length;
    BOOL isApplyingChecklist            = [cleanLineString hasPrefix:textAttachmentCode];
    NSInteger indexOfBullet             = [lineString rangeOfString:isApplyingChecklist
                                           ? textAttachmentCode
                                           : stringToAppendToNewLine].location;
    NSRange newSelectedRange            = self.selectedRange;
    NSString *insertionString           = nil;
    NSRange insertionRange              = lineRange;
    
    // Tab entered: Move the bullet along
    if (replacementText.isTabString) {
        if (isApplyingChecklist) {
            return NO;
        }
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
        newSelectedRange.location       -= lineRange.length - (isApplyingChecklist ? 1 :  bulletLength);
        
    // Attempt to apply the bullet
    } else  {
        // Substring: [0 - Bullet]
        if (isApplyingChecklist) {
            NSRange bulletPrefixRange       = NSMakeRange(0, [lineString rangeOfString:textAttachmentCode].location);
            stringToAppendToNewLine         = [[lineString substringWithRange:bulletPrefixRange] stringByAppendingString:stringToAppendToNewLine];
        } else {
            NSRange bulletPrefixRange       = NSMakeRange(0, [lineString rangeOfString:stringToAppendToNewLine].location + 1);
            stringToAppendToNewLine         = [lineString substringWithRange:bulletPrefixRange];
        }
        
        // Do we need to append a whitespace?
        if (lineRange.length > indexOfBullet + bulletLength && !isApplyingChecklist) {
            unichar bulletTrailing      = [lineString characterAtIndex:indexOfBullet + bulletLength];
            
            if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:bulletTrailing]) {
                NSString *trailing      = [NSString stringWithFormat:@"%c", bulletTrailing];
                stringToAppendToNewLine = [stringToAppendToNewLine stringByAppendingString:trailing];
            }
        }
        
        // Replacement + NewRange
        insertionString                 = [[NSString newLineString] stringByAppendingString:stringToAppendToNewLine];
        insertionRange                  = replacementRange;
        newSelectedRange.location       += isApplyingChecklist ? [stringToAppendToNewLine length] - ChecklistItemLength : insertionString.length;
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
    
    // Set the capitalization type to 'Words' temporarily so that we get a capital word next to the bullet.
    self.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [self reloadInputViews];
    
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
