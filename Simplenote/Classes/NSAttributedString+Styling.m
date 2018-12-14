//
//  NSAttributedString+Styling.m
//  Simplenote
//
//  Created by Tom Witkin on 8/8/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "NSAttributedString+Styling.h"
#import "UIImage+Extensions.h"
#import "UIImage+Colorization.h"
#import "Simplenote-Swift.h"

@implementation NSAttributedString (Styling)

+ (NSAttributedString *)attributedStringWithImage:(UIImage *)image {
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setImage:image];
    
    NSMutableAttributedString *attachmentString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    
    // add a space after image to provide padding.
    [attachmentString appendAttributedString:[[NSAttributedString alloc] initWithString:@"  "]];
    
    return attachmentString;
}

- (NSAttributedString *)attributedStringWithLeadingImage:(UIImage *)image lineHeight:(CGFloat)lineHeight {
    
    // Make new leading image based on lineheight. This ensures that it
    // is centered vertically in the first line of text.
    UIImage *newImage = [image imageInCanvas:CGRectMake(0, 0, image.size.width, lineHeight)];
    
    NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithImage:newImage];
    NSMutableAttributedString *combinedString = [[NSMutableAttributedString alloc] initWithAttributedString:imageAttributedString];
    [combinedString appendAttributedString:self];
    
    return combinedString;
}

// Replaces checklist markdown syntax with SPTextAttachment images in an attributed string
+ (NSAttributedString *)attributedStringWithChecklistAttachments: (NSAttributedString *)sourceString withColor: (UIColor *)color {
    if (!sourceString || sourceString.length == 0) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:CheckListRegExPattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    
    NSString *noteString = sourceString.string;
    NSArray *matches = [regex matchesInString:noteString options:0 range:[noteString rangeOfString:noteString]];
    
    if (matches.count == 0) {
        return sourceString;
    }
    
    NSMutableAttributedString *newString = [[NSMutableAttributedString alloc] initWithAttributedString:sourceString];
    
    int positionAdjustment = 0;
    for (NSTextCheckingResult *match in matches) {
        NSString *markdownTag = [noteString substringWithRange:match.range];
        BOOL isChecked = [markdownTag containsString:@"x"];
        
        SPTextAttachment *attachment = [[SPTextAttachment alloc] initWithColor: color];
        [attachment setIsChecked: isChecked];
        CGFloat fontSize = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize + 4;
        attachment.bounds = CGRectMake(0, -4.5, fontSize, fontSize);
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSRange adjustedRange = NSMakeRange(match.range.location - positionAdjustment, match.range.length);
        [newString replaceCharactersInRange:adjustedRange withAttributedString:attachmentString];
        
        positionAdjustment += markdownTag.length - 1;
    }
    
    return newString;
}

@end
