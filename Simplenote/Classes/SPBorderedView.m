//
//  SPBorderedView.m
//  Simplenote
//
//  Created by Tom Witkin on 7/28/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPBorderedView.h"

@implementation SPBorderedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _borderWidth = 1 / [[UIScreen mainScreen] scale];
        _borderInset = UIEdgeInsetsZero;
        _fillColor = [UIColor whiteColor];
        _borderColor = [UIColor blackColor];
        _cornerRadius = 0.0;
        
        self.backgroundColor = [UIColor clearColor];
        
        _showBottomBorder = YES;
        _showTopBorder = YES;
        _showLeftBorder = YES;
        _showRightBorder = YES;
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    [super drawRect:rect];
    
    // create fill box
    [_fillColor setFill];

    CGRect fillRect = CGRectMake(_borderInset.left,
                                 _borderInset.top,
                                 rect.size.width - _borderInset.left - _borderInset.right,
                                 rect.size.height - _borderInset.top - _borderInset.bottom);
    
    if (_cornerRadius > 0)
        [[UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:_cornerRadius] fill];
    else
        [[UIBezierPath bezierPathWithRect:fillRect] fill];
    
    //borders
    [_borderColor setFill];
    
    if (_showLeftBorder) {
        
        CGRect leftBorderRect = CGRectMake(_borderInset.left,
                                           _borderInset.top,
                                           _borderWidth,
                                           rect.size.height - _borderInset.top - _borderInset.bottom);
        [[UIBezierPath bezierPathWithRect:leftBorderRect] fill];

    }
    
    if (_showRightBorder) {
        
        CGRect rightBorderRect = CGRectMake(rect.size.width - _borderInset.left - _borderWidth,
                                            _borderInset.top,
                                            _borderWidth,
                                            rect.size.height - _borderInset.top - _borderInset.bottom);
        [[UIBezierPath bezierPathWithRect:rightBorderRect] fill];

    }
    
    if (_showTopBorder) {
        
        CGRect topBorderRect = CGRectMake(_borderInset.left,
                                          _borderInset.top,
                                          rect.size.width - _borderInset.left - _borderInset.right,
                                          _borderWidth);
        [[UIBezierPath bezierPathWithRect:topBorderRect] fill];

    }
    
    if (_showBottomBorder) {
        
        CGRect bottomBorderRect = CGRectMake(_borderInset.left,
                                             rect.size.height - _borderInset.top - _borderInset.bottom - _borderWidth,
                                             rect.size.width - _borderInset.left - _borderInset.right,
                                             _borderWidth);
        [[UIBezierPath bezierPathWithRect:bottomBorderRect] fill];

    }
    
}


@end
