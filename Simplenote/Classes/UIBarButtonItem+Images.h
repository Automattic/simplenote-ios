//
//  UIBarButtonItem+Images.h
//  Simplenote
//
//  Created by Tom Witkin on 7/11/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	UIBarButtonImageAlignmentRight,
    UIBarButtonImageAlignmentLeft
} UIBarButtonImageAlignment;

@interface UIBarButtonItem (Images)

+ (UIBarButtonItem *)barButtonWithImage:(UIImage *)image imageAlignment:(UIBarButtonImageAlignment)imageAlignment target:(id)target selector:(SEL)action;

// custom views can be important if the button needs to be animated in some way
+ (UIBarButtonItem *)barButtonContainingCustomViewWithImage:(UIImage *)image imageAlignment:(UIBarButtonImageAlignment)imageAlignment target:(id)target selector:(SEL)action;
    
+ (UIBarButtonItem *)barButtonFixedSpaceWithWidth:(CGFloat)width;

/// @return A UIBarButtonItem including a custom chevron and a title
+ (UIBarButtonItem *)backBarButtonWithTitle:(NSString *)title
                                     target:(id)target
                                     action:(SEL)action;

@end
