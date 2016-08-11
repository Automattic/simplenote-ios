//
//  SPTransitionSnapshot.m
//  Simplenote
//
//  Created by Tom Witkin on 8/26/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTransitionSnapshot.h"

NSString *const SPAnimationAlphaValueName = @"SPAnimationAlphaValueName";
NSString *const SPAnimationFrameValueName = @"SPAnimationFrameValueName";

NSString *const SPAnimationInitialValueName = @"SPAnimationInitialValueName";
NSString *const SPAnimationFinalValueName = @"SPAnimationFinalValueName";

NSString *const SPAnimationDurationName = @"SPAnimationDurationName";
NSString *const SPAnimationDelayName = @"SPAnimationDelayName";
NSString *const SPAnimationSpringDampingName = @"SPAnimationSpringDampingName";
NSString *const SPAnimationInitialVeloctyName = @"SPAnimationInitialVeloctyName";
NSString *const SPAnimationOptionsName = @"SPAnimationOptionsName";

@implementation SPTransitionSnapshot

- (id)initWithSnapshot:(UIView *)snapshot animatedValues:(NSDictionary *)animatedValues animationProperties:(NSDictionary *)animationProperties superView:(UIView *)superView {
    
    self = [super init];
    if (self) {
        
        self.snapshot = snapshot;
        self.animatedValues = animatedValues;
        self.animationProperties = animationProperties;
        self.springAnimation = YES;
        
        [self setPercentComplete:0.0 animated:NO completion:nil];
        
        [superView addSubview:snapshot];
    }
    
    return self;
}

- (CGRect)interpolatedRectBetweenIntialRect:(CGRect)initialRect finalRect:(CGRect)finalRect percent:(CGFloat)percent {
    
    CGRect newRect = CGRectZero;
    newRect.origin.x = [self interpolatedFloatBetweenInitialFloat:initialRect.origin.x
                                                       finalFloat:finalRect.origin.x
                                                          percent:percent];
    newRect.origin.y = [self interpolatedFloatBetweenInitialFloat:initialRect.origin.y
                                                       finalFloat:finalRect.origin.y
                                                          percent:percent];
    newRect.size.width = [self interpolatedFloatBetweenInitialFloat:initialRect.size.width
                                                       finalFloat:finalRect.size.width
                                                          percent:percent];
    newRect.size.height = [self interpolatedFloatBetweenInitialFloat:initialRect.size.height
                                                       finalFloat:finalRect.size.height
                                                          percent:percent];
    
    return newRect;
}

- (CGFloat)interpolatedFloatBetweenInitialFloat:(CGFloat)initialFloat finalFloat:(CGFloat)finalFloat percent:(CGFloat)percent {
    
    if (percent >= 1.0)
        return finalFloat;
    else if (percent <= 0.0)
        return initialFloat;
    else
        return initialFloat + (finalFloat - initialFloat) * percent;
}

- (CGFloat)percentComplete {
    
    return percentComplete;
}

- (void)setPercentComplete:(CGFloat)percent animated:(BOOL)animated completion:(void (^)())completion {
    
    if (percent > 1.0)
        percent = 1.0;
    else if (percent < 0.0)
        percent = 0.0;
    
    CGFloat duration = [(NSNumber *)_animationProperties[SPAnimationDurationName] floatValue];
    CGFloat delay = [(NSNumber *)_animationProperties[SPAnimationDelayName] floatValue];
    
    // calculate percantage used for interpolated value. This could be different if there is a delay
    // added to the animationProperties
    CGFloat totalTime = delay + duration;
    CGFloat elapsedTimeForPercent = totalTime * percent;
    CGFloat elapsedAnimatedTimeForPercent = elapsedTimeForPercent - delay;
    CGFloat interpolatedPercent = elapsedAnimatedTimeForPercent > 0.0 ? elapsedAnimatedTimeForPercent / duration : 0.0;
    
    CGFloat elapsedTimeForCurrentPercent = totalTime * percentComplete;
    CGFloat elapsedAnimatedTimeForCurrentPercent = elapsedTimeForCurrentPercent - delay;
    
    // calculate animation durations;
    CGFloat animationDuration = elapsedAnimatedTimeForCurrentPercent > 0.0 ? duration - elapsedTimeForCurrentPercent : duration;
    CGFloat animationDelay = elapsedAnimatedTimeForCurrentPercent > 0.0 ? 0.0 : delay - elapsedTimeForCurrentPercent;
    
    void (^animationBlock)();
    
    animationBlock = ^() {
        
        [_animatedValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            if ([key isEqualToString:SPAnimationAlphaValueName]) {
                
                CGFloat interpolatedValue = [self interpolatedFloatBetweenInitialFloat:[(NSNumber *)[(NSDictionary *)obj objectForKey:SPAnimationInitialValueName] floatValue]
                                                                            finalFloat:[(NSNumber *)[(NSDictionary *)obj objectForKey:SPAnimationFinalValueName] floatValue]
                                                                               percent:interpolatedPercent];
                _snapshot.alpha = interpolatedValue;
            } else if ([key isEqualToString:SPAnimationFrameValueName]) {
                
                CGRect interpolatedRect = [self interpolatedRectBetweenIntialRect:[(NSValue *)[(NSDictionary *)obj objectForKey:SPAnimationInitialValueName] CGRectValue]
                                                                        finalRect:[(NSValue *)[(NSDictionary *)obj objectForKey:SPAnimationFinalValueName] CGRectValue]
                                                                          percent:interpolatedPercent];
                _snapshot.frame = interpolatedRect;
            }
            
        }];
        
    };
    
    void (^completionBlock)();
    
    completionBlock = ^() {
        
        percentComplete = percent;

        if (completion)
            completion();
    };
    
    
    if (animated) {
        
        if (_springAnimation) {
            
            [UIView animateWithDuration:animationDuration
                                  delay:animationDelay
                 usingSpringWithDamping:[(NSNumber *)_animationProperties[SPAnimationSpringDampingName] floatValue]
                  initialSpringVelocity:[(NSNumber *)_animationProperties[SPAnimationInitialVeloctyName] floatValue]
                                options:[(NSNumber *)_animationProperties[SPAnimationOptionsName] intValue]
                             animations:^{
                                 
                                 animationBlock();
                                 
                             } completion:^(BOOL finished) {
                                 
                                 completionBlock();
                             }];
        } else {
            
            [UIView animateWithDuration:animationDuration
                                  delay:animationDelay
                                options:[(NSNumber *)_animationProperties[SPAnimationOptionsName] intValue]
                             animations:^{
                                 
                                 animationBlock();
                             }
                             completion:^(BOOL finished) {
                                 
                                 completionBlock();
                             }];
        }
        
    } else {
        
        [UIView performWithoutAnimation:^{
            animationBlock();
            completionBlock();
        }];
    }
}

@end
