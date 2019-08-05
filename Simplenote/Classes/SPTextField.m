//
//  SPTextField.m
//  Simplenote
//
//  Created by Tom Witkin on 10/13/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTextField.h"

@implementation SPTextField

- (void)drawPlaceholderInRect:(CGRect)rect
{    
    if (_placeholdTextColor && self.placeholder.length > 0) {
        
        [_placeholdTextColor setFill];
        
        // get size of placeholder
        CGSize placeholderSize = [self.placeholder sizeWithAttributes:@{NSFontAttributeName: self.font}];
        
        CGFloat xOrigin;
        if (self.textAlignment == NSTextAlignmentRight)
            xOrigin = rect.size.width - placeholderSize.width;
        else if (self.textAlignment == NSTextAlignmentCenter)
            xOrigin = (rect.size.width - placeholderSize.width) / 2.0;
        else
            xOrigin = rect.origin.x;
        
        [[self placeholder] drawInRect:CGRectMake(xOrigin,
                                                  (rect.size.height - placeholderSize.height) / 2.0,
                                                  rect.size.width,
                                                  placeholderSize.height)
                        withAttributes:@{NSFontAttributeName: self.font,
                                         NSForegroundColorAttributeName: _placeholdTextColor}];
    } else
        [super drawPlaceholderInRect:rect];
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect textRect = [super rightViewRectForBounds:bounds];
    if (CGRectGetWidth(textRect) > 0) {
        textRect.origin.x -= _rightViewInsets.right;
    }

    return textRect;
}

@end
