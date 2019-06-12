//
//  SPEmptyListView.m
//  Simplenote
//
//  Created by Tom Witkin on 8/5/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPEmptyListView.h"
#import "VSThemeManager.h"
#import "UIImage+Colorization.h"

@implementation SPEmptyListView

- (id)initWithImage:(UIImage *)image withText:(NSString *)text {
    
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self setupWithImage:image text:text];
    }
    return self;
    
}

- (void)layoutSubviews {
    
    CGFloat verticalPadding = 10.0;
    CGFloat imageViewHeight = hideImageView ? 0.0 : _imageView.image.size.height;
    CGFloat textLabelHeight = [_textLabel sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)].height;
    CGFloat totalItemHeight = textLabelHeight + imageViewHeight;
    
    _imageView.frame = CGRectMake(0.0,
                                  MAX(0.0, (self.frame.size.height - totalItemHeight) / 2.0),
                                  self.frame.size.width,
                                  imageViewHeight);
    
    _textLabel.frame = CGRectMake(0.0,
                                  _imageView.frame.origin.y + imageViewHeight + verticalPadding,
                                  self.frame.size.width,
                                  textLabelHeight);
}

- (void)setupWithImage:(UIImage *)image text:(NSString *)text {
        
    _imageView = [[UIImageView alloc] initWithImage:image];
    _imageView.contentMode = UIViewContentModeCenter;
    _imageView.alpha = 0.5;
    [self addSubview:_imageView];
    
    _textLabel = [[UILabel alloc] init];
    _textLabel.text = text;
    _textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.numberOfLines = 0;
    _textLabel.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_textLabel];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [self setColor:[[[VSThemeManager sharedManager] theme] colorForKey:@"emptyListViewFontColor"]];
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text {
    
    _textLabel.text = text;
    [self setNeedsLayout];
}
- (void)setImage:(UIImage *)image {
    
    [_imageView setImage:image];
    [self setNeedsLayout];
}

- (void)setColor:(UIColor *)color {
    
    _textLabel.textColor = color;
    _imageView.image = [_imageView.image imageWithOverlayColor:color];
}

- (void)hideImageView:(BOOL)hide {
    
    _imageView.hidden = hide;
    hideImageView = hide;
}

@end
