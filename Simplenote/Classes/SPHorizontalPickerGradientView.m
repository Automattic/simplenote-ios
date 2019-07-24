//
//  SPHorizontalPickerGradientView.m
//  Simplenote
//
//  Created by Tom Witkin on 7/30/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPHorizontalPickerGradientView.h"
#import "Simplenote-Swift.h"


@implementation SPHorizontalPickerGradientView

- (id)initWithGradientViewDirection:(SPHorizontalPickerGradientViewDirection)direction {
    
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        gradientDirection = direction;
        self.userInteractionEnabled = NO;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    CGFloat borderWidth = 1.0 / [[UIScreen mainScreen] scale];
    
    // draw border based on gradient direction
    CGFloat xOrigin = gradientDirection == SPHorizontalPickerGradientViewDirectionLeft ? rect.size.width - borderWidth : 0.0;
    
    CGRect borderRect = CGRectMake(xOrigin, 0, borderWidth, rect.size.height);
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:borderRect];
    [[[[VSThemeManager sharedManager] theme] colorForKey:@"horizontalPickerBorderColor"] setFill];
    [borderPath fill];
    
    
    
    if (!gradientLayer) {
        
        NSArray *gradientColors = [NSArray arrayWithObjects:(id)[[[[VSThemeManager sharedManager] theme] colorForKey:@"actionSheetBackgroundColor"] colorWithAlphaComponent:0.0].CGColor, (id)[[[VSThemeManager sharedManager] theme] colorForKey:@"actionSheetBackgroundColor"].CGColor, nil];
		
        BOOL leftToRight = gradientDirection == SPHorizontalPickerGradientViewDirectionLeft;
        gradientLayer = [CAGradientLayer layer];
        [gradientLayer setLocations:@[@0.0001]];
        [gradientLayer setStartPoint:CGPointMake(leftToRight ? 1.0 : 0.0, 0.5)];
        [gradientLayer setEndPoint:CGPointMake(leftToRight ? 0.0 : 1.0, 0.5)];
        [gradientLayer setColors:gradientColors];
        [[self layer] addSublayer:gradientLayer];
    }
    [gradientLayer setFrame:rect];
    
    
}

@end
