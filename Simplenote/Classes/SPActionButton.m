//
//  SPActionButton.m
//  Simplenote
//
//  Created by Tom Witkin on 7/27/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPActionButton.h"
#import "Simplenote-Swift.h"

static CGFloat const imageSide = 34.0;

@implementation SPActionButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }

    return self;
}


- (void)layoutSubviews {

    [super layoutSubviews];

    
    // center images in background
    
    self.imageView.frame = CGRectMake((self.bounds.size.width - imageSide) / 2.0,
                                      10 + (60 - imageSide) / 2.0,
                                      imageSide,
                                      imageSide);
    
    CGFloat titleLabelYOrigin = 10 + 60;
    self.titleLabel.frame = CGRectMake(0,
                                       titleLabelYOrigin,
                                       self.bounds.size.width,
                                       self.bounds.size.height - titleLabelYOrigin);
}

- (void)setupViews {
    
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    UIColor *titleColorNormal = [UIColor simplenoteTintColor];
    UIColor *actionDisabledColor = [UIColor colorWithName:UIColorNameActionViewButtonDisabledColor];

    [self setTitleColor:titleColorNormal forState:UIControlStateNormal];
    [self setTitleColor:actionDisabledColor forState:UIControlStateDisabled];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}


@end
