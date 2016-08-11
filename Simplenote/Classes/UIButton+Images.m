//
//  UIButton+Images.m
//  Simplenote
//
//  Created by Tom Witkin on 7/15/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "UIButton+Images.h"

@implementation UIButton (Images)

+ (UIButton *)buttonWithImage:(UIImage *)image target:(id)target selector:(SEL)action {
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  image.size.width,
                                                                  image.size.height)];
    
    // use UIImageRenderingModeAlwaysTemplate to get button to adopt tint color
    [button setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
            forState:UIControlStateNormal];
    [button addTarget:target
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
    
}

@end
