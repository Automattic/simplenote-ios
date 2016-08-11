//
//  SPModalActivityIndicator.h
//  Simplenote
//
//  Created by Tom Witkin on 8/30/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPModalActivityIndicator : UIView {
    
    CGRect boxFrame;

    UIView *parentView;
    UIView *topView;
}

@property (nonatomic, retain) UIView *contentView;

+ (SPModalActivityIndicator *)show;
- (void)dismiss:(BOOL)animated completion:(void (^)())completion;

@end
