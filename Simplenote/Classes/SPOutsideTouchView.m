//
//  SPOusideTouchView.m
//  Simplenote
//
//  Created by Tom Witkin on 8/10/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPOutsideTouchView.h"

@implementation SPOutsideTouchView

// allow touches outside view
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    for(UIView *subview in self.subviews)
    {
        UIView *view = [subview hitTest:[self convertPoint:point toView:subview] withEvent:event];
        if(view) return view;
    }
    return [super hitTest:point withEvent:event];
}

@end
