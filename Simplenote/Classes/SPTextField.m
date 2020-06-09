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
    return [self applyAccessoryInsetsToTextBounds:output];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect output = [super editingRectForBounds:bounds];
    return [self applyAccessoryInsetsToTextBounds:output];
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    // Invoked in LTR Mode. Let's not adjust the width, since it'd skew the Right Image
    CGRect output = [super rightViewRectForBounds:bounds];
    if (CGRectGetWidth(output) > 0) {
        output.origin.x -= self.rightViewInsets.trailing;
    }

    return output;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    // Invoked in RTL Mode. Let's not adjust the width, since it'd skew the Right Image
    CGRect output = [super leftViewRectForBounds:bounds];
    if (CGRectGetWidth(output) > 0) {
        output.origin.x += self.rightViewInsets.leading;
    }

    return output;
}

- (CGRect)applyAccessoryInsetsToTextBounds:(CGRect)frame
{
    if (self.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight) {
        frame.size.width -= self.rightViewInsets.trailing;
        return frame;
    }

    frame.origin.x += self.rightViewInsets.leading;
    frame.size.width -= self.rightViewInsets.leading;

    return frame;
}

@end
