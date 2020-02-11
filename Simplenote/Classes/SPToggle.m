//
//  TWSwitch.m
//  Podcasts
//
//  Created by Tom Witkin on 1/9/13.
//  Copyright (c) 2013 Tom Witkin. All rights reserved.
//

#import "SPToggle.h"


@implementation SPToggle



- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setOn:NO];
        [self addTarget:self action:@selector(didTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
    
}


- (void)didTouchUpInside {
        
    // change is on and call value changed
    [self setOn:!self.isOn];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
}


- (BOOL)isOn {
    
    if (isOn == YES)
        
        return YES;
    
    else
        
        return NO;
    
}

- (BOOL)on {
    
    return [self isOn];
}

- (void)setOn:(BOOL)on {
    
    BOOL swapImages = on != isOn;
    
    isOn = on;
    
    // swap the highlighted images
    
    if (swapImages) {
        
        UIImage *newImage = [self imageForState:UIControlStateHighlighted];
        UIImage *newHighlightImage = [self imageForState:UIControlStateNormal];
        UIImage *newBackgroundImage = [self backgroundImageForState:UIControlStateHighlighted];
        UIImage *newBackgroundHighlightImage = [self backgroundImageForState:UIControlStateNormal];
        UIColor *newTitleColor = [self titleColorForState:UIControlStateHighlighted];
        UIColor *newHighlightTitleColor = [self titleColorForState:UIControlStateNormal];
        NSString *newTitle = [self titleForState:UIControlStateHighlighted];
        NSString *newHighlightTitle = [self titleForState:UIControlStateNormal];
        
        [self setImage:newImage forState:UIControlStateNormal];
        [self setImage:newHighlightImage forState:UIControlStateHighlighted];
        [self setBackgroundImage:newBackgroundImage forState:UIControlStateNormal];
        [self setBackgroundImage:newBackgroundHighlightImage forState:UIControlStateHighlighted];
        [self setTitleColor:newTitleColor forState:UIControlStateNormal];
        [self setTitleColor:newHighlightTitleColor forState:UIControlStateHighlighted];
        [self setTitle:newTitle forState:UIControlStateNormal];
        [self setTitle:newHighlightTitle forState:UIControlStateHighlighted];
    }
    
    
    
}

@end
