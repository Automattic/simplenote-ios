//
//  UIView+Subviews.h
//  Simplenote
//
//  Created by Tom Witkin on 8/5/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Subviews)

- (NSArray *)subviewsRespondingToSelector:(SEL)selector;

@end
