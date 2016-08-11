//
//  SPButton.m
//  Simplenote
//
//  Created by Tom Witkin on 7/16/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPButton.h"

@implementation SPButton
@synthesize backgroundHighlightColor;

 
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addObserver:self
               forKeyPath:@"highlighted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        
        self.layer.cornerRadius = 0;
    }
    
    return self;
}

- (void)dealloc {
    
    [self removeObserver:self forKeyPath:@"highlighted"];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    for (UIView *view in self.subviews) {
        
        if (view.class == [UIImageView class])
            [(UIImageView *)view setHighlighted:self.highlighted];
        
    }
    
    [self setNeedsDisplay];
    
}

- (void)drawRect:(CGRect)rect
{
    if (self.highlighted == YES)
        self.layer.backgroundColor = backgroundHighlightColor.CGColor;
    else
        self.layer.backgroundColor = backgroundColor.CGColor;

}

- (void)setBackgroundColor:(UIColor *)bgcolor {
    
    backgroundColor = bgcolor;
}
- (void)setBackgroundHighlightColor:(UIColor *)bgHighlightColor {
    
    backgroundHighlightColor = bgHighlightColor;
}


@end
