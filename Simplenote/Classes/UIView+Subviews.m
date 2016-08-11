//
//  UIView+Subviews.m
//  Simplenote
//
//  Created by Tom Witkin on 8/5/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "UIView+Subviews.h"

@implementation UIView (Subviews)


- (NSArray *)subviewsRespondingToSelector:(SEL)selector {
    
    NSMutableArray *foundSubviews = [NSMutableArray arrayWithCapacity:1];
    
    for (UIView *subview in self.subviews) {
        
        // check the response of this subview
        if ([subview respondsToSelector:selector])
            [foundSubviews addObject:subview];
        
        // check all subviews of current subview
        NSArray *foundSubSubviews = [subview subviewsRespondingToSelector:selector];
        if (foundSubSubviews.count > 0)
            [foundSubviews addObjectsFromArray:foundSubSubviews];
        
    }
    
    
    return foundSubviews;
}



@end
