//
//  SPSideBySideView.m
//  Simplenote
//
//  Created by Tom Witkin on 7/30/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPSideBySideView.h"

@implementation SPSideBySideView

- (id)initWithFirstView:(UIView *)fv secondView:(UIView *)sv {
    
    CGFloat height = MAX(fv.frame.size.height, sv.frame.size.height);
    CGFloat width = MAX(fv.frame.size.width, sv.frame.size.width);
    
    fv.frame = CGRectMake(0, 0, width, height);
    sv.frame = CGRectMake(width, 0, width, height);
    
    
    
    self = [[SPSideBySideView alloc] initWithFrame:CGRectMake(0, 0, 2 * width, height)];
    if (self) {
        
        [self addSubview:fv];
        [self addSubview:sv];
        
        firstView = fv;
        secondView = sv;
    }


    return self;
}

- (void)layoutSubviews {
    
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width / 2.0;
    
    firstView.frame = CGRectMake(0, 0, width, height);
    secondView.frame = CGRectMake(width, 0, width, height);
    
    
}

@end
