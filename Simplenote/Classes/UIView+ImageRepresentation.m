//
//  UIView+ImageRepresentation.m
//  Podcasts
//
//  Created by Tom Witkin on 2/18/13.
//  Copyright (c) 2013 Tom Witkin. All rights reserved.
//

#import "UIView+ImageRepresentation.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (ImageRepresentation)

- (UIImage *)imageRepresentation {
    
    CGSize imageSize = [self frame].size;
    BOOL imageIsOpaque = [self isOpaque];
    CGFloat imageScale = 0.0; // automatically set to scale factor of main screen
    UIGraphicsBeginImageContextWithOptions(imageSize, imageIsOpaque, imageScale);
    CALayer * drawingLayer = [self layer];
    [drawingLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImageView *)imageRepresentationWithinImageView {
    
    UIImage *image = [self imageRepresentation];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    imageView.contentMode = UIViewContentModeTopLeft;
    return imageView;
}

@end
