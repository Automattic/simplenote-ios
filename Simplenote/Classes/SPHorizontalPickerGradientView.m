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

- (instancetype)initWithGradientViewDirection:(SPHorizontalPickerGradientViewDirection)direction
{    
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

- (void)drawRect:(CGRect)rect
{
    CGFloat borderWidth = 1.0 / [[UIScreen mainScreen] scale];
    
    // draw border based on gradient direction
    CGFloat xOrigin = gradientDirection == SPHorizontalPickerGradientViewDirectionLeft ? rect.size.width - borderWidth : 0.0;
    
    CGRect borderRect = CGRectMake(xOrigin, 0, borderWidth, rect.size.height);
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:borderRect];
    [[UIColor simplenoteDividerColor] setFill];
    [borderPath fill];

    if (!gradientLayer) {
        BOOL leftToRight = gradientDirection == SPHorizontalPickerGradientViewDirectionLeft;
        gradientLayer = [CAGradientLayer layer];
        [gradientLayer setLocations:@[@0.0001]];
        [gradientLayer setStartPoint:CGPointMake(leftToRight ? 1.0 : 0.0, 0.5)];
        [gradientLayer setEndPoint:CGPointMake(leftToRight ? 0.0 : 1.0, 0.5)];
        [gradientLayer setColors:self.gradientColors];
        [[self layer] addSublayer:gradientLayer];
    }
    [gradientLayer setFrame:rect];
}

- (NSArray *)gradientColors
{
    UIColor *actionSheetBackgroundColor = [UIColor simplenoteTableViewBackgroundColor];
    NSArray *gradientColors = @[
        (id)[actionSheetBackgroundColor colorWithAlphaComponent:0.0].CGColor,
        (id)actionSheetBackgroundColor.CGColor
    ];

    return gradientColors;
}

- (void)refreshStyle
{
    gradientLayer.colors = [self gradientColors];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

    if (@available(iOS 13.0, *)) {
        if ([previousTraitCollection hasDifferentColorAppearanceComparedToTraitCollection:self.traitCollection] == false) {
            return;
        }

        [self refreshStyle];
    }
}

@end
