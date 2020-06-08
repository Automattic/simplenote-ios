//
//  SPTextField.m
//  Simplenote
//
//  Created by Tom Witkin on 10/13/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTextField.h"
#import "Simplenote-Swift.h"

@implementation SPTextField

- (void)drawPlaceholderInRect:(CGRect)rect
{    
    if (self.placeholdTextColor == nil || self.placeholder.length == 0) {
        [super drawPlaceholderInRect:rect];
        return;
    }

    [self.placeholder drawInRect:rect withAttributes:@{
        NSFontAttributeName: self.font,
        NSForegroundColorAttributeName: self.placeholdTextColor
    }];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect output = [super textRectForBounds:bounds];
    if (self.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight) {
        output.size.width -= self.rightViewInsets.leading;
    } else {
        output.origin.x += self.rightViewInsets.trailing;
        output.size.width -= self.rightViewInsets.trailing;
    }

    return output;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect output = [super editingRectForBounds:bounds];
    if (self.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight) {
        output.size.width -= self.rightViewInsets.leading;
    } else {
        output.origin.x += self.rightViewInsets.trailing;
        output.size.width -= self.rightViewInsets.trailing;
    }

    return output;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    // Invoked by the SDK only in Left to Right Mode
    CGRect output = [super rightViewRectForBounds:bounds];
    if (CGRectGetWidth(output) > 0) {
        output.origin.x -= self.rightViewInsets.trailing;
    }

    return output;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    // Invoked by the SDK only in Right to Left Mode
    CGRect output = [super leftViewRectForBounds:bounds];
    if (CGRectGetWidth(output) > 0) {
        output.origin.x += self.rightViewInsets.leading;
    }

    return output;
}

@end
