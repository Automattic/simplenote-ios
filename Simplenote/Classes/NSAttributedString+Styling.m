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

@end
