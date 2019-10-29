//
//  UIBarButtonItem+Images.m
//  Simplenote
//
//  Created by Tom Witkin on 7/11/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "UIBarButtonItem+Images.h"
#import "SPOutsideTouchView.h"
#import "UIDevice+Extensions.h"
#import "Simplenote-Swift.h"


static CGFloat const UIBarButtonSidePaddingPad      = 9.0;
static CGFloat const UIBarButtonSidePaddingPhone    = 13.0;
static CGFloat const UIBarButtonWidth               = 44.0;

@implementation UIBarButtonItem (Images)

+ (UIBarButtonItem *)barButtonWithImage:(UIImage *)image imageAlignment:(UIBarButtonImageAlignment)imageAlignment target:(id)target selector:(SEL)action
{    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:image
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:target
                                                                 action:action];
    return button;
    
}

+ (UIBarButtonItem *)barButtonContainingCustomViewWithImage:(UIImage *)image imageAlignment:(UIBarButtonImageAlignment)imageAlignment target:(id)target selector:(SEL)action
{
    CGFloat sideAdjustment = [UIDevice isPad] ? UIBarButtonSidePaddingPad : UIBarButtonSidePaddingPhone;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(imageAlignment == UIBarButtonImageAlignmentLeft ? -sideAdjustment : 0,
                                                                  -1,
                                                                  UIBarButtonWidth,
                                                                  image.size.height)];
    button.isAccessibilityElement = NO;

    // use UIImageRenderingModeAlwaysTemplate to get button to adopt tint color
    [button setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
            forState:UIControlStateNormal];
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    button.adjustsImageWhenDisabled = YES;
    
    return [self containerViewWithButton:button];
}

+ (UIBarButtonItem *)backBarButtonWithTitle:(NSString *)title
                                     target:(id)target
                                     action:(SEL)action
{    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIColor *tintColor = [UIColor simplenoteTintColor];
    UIImage *backImage = [UIImage imageWithName:UIImageNameChevronLeft];

    [button setImage:[backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
            forState:UIControlStateNormal];

    // Inset by -1 to match notes list chevron position
    [button setImageEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 0)];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:tintColor forState:UIControlStateNormal];
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    button.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    [button sizeToFit];
    
    return [self containerViewWithButton:button];
}

+ (UIBarButtonItem *)barButtonFixedSpaceWithWidth:(CGFloat)width
{
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                target:nil
                                                                                action:nil];
    fixedSpace.width = width;
    
    return fixedSpace;
    
}

+ (UIBarButtonItem *)containerViewWithButton:(UIButton *)button
{
    CGFloat sideAdjustment = [UIDevice isPad] ? UIBarButtonSidePaddingPad : UIBarButtonSidePaddingPhone;
    
    // the intermediateView allows the button to be pushed ouside the bounds of the view,
    // providing more fine tuned adjustment of the position
    CGRect intermediateViewBounds = button.bounds;
    intermediateViewBounds.size.width -= sideAdjustment;
    SPOutsideTouchView *intermediateView = [[SPOutsideTouchView alloc] initWithFrame:intermediateViewBounds];
    [intermediateView addSubview:button];
    
    UIBarButtonItem *container = [[UIBarButtonItem alloc] initWithCustomView:intermediateView];
    return container;
}

@end
