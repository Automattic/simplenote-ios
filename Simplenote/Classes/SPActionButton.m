//
//  SPActionButton.m
//  Simplenote
//
//  Created by Tom Witkin on 7/27/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPActionButton.h"
#import "VSThemeManager.h"

static CGFloat const imageSide = 34.0;

@implementation SPActionButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        initialSetupComplete = NO;
    }
    return self;
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self setupViews];
    
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
    self.titleLabel.font = [[[VSThemeManager sharedManager] theme] fontForKey:@"actionButtonFont"];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self setTitleColor:[[[VSThemeManager sharedManager] theme] colorForKey:@"tintColor"]
               forState:UIControlStateNormal];
    [self setTitleColor:[[[VSThemeManager sharedManager] theme] colorForKey:@"actionViewButtonDisabledColor"]
               forState:UIControlStateDisabled];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;

    initialSetupComplete = YES;
}


@end
