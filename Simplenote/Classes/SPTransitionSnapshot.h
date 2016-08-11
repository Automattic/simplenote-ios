//
//  SPTransitionSnapshot.h
//  Simplenote
//
//  Created by Tom Witkin on 8/26/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const SPAnimationAlphaValueName;
NSString *const SPAnimationFrameValueName;

NSString *const SPAnimationInitialValueName;
NSString *const SPAnimationFinalValueName;

NSString *const SPAnimationDurationName;
NSString *const SPAnimationDelayName;
NSString *const SPAnimationSpringDampingName;
NSString *const SPAnimationInitialVeloctyName;
NSString *const SPAnimationOptionsName;

@interface SPTransitionSnapshot : NSObject {
    
    CGFloat percentComplete;
}

@property (nonatomic, strong) UIView *snapshot;

@property (nonatomic) BOOL springAnimation;

// Dictionary of dictionarys of animated values where the dictionaries are keyed by the property they are adjusting. Example: animationValues contains a dictionary with key of "frame" with two objects keyed "SPAnimationInitialValueName" and "SPAnimationFinalValueName". These dictionaries containe NSValue or NSNumber objects;
@property (nonatomic) NSDictionary *animatedValues;

// Dictionary of NSNumbers with the associated animation properties, including duration, delay, spring damping, and initial spring velocity
@property (nonatomic) NSDictionary *animationProperties;

- (id)initWithSnapshot:(UIView *)snapshot
        animatedValues:(NSDictionary *)animatedValues
   animationProperties:(NSDictionary *)animationProperties
             superView:(UIView *)superView;

- (CGFloat)percentComplete;
- (void)setPercentComplete:(CGFloat)percent animated:(BOOL)animated completion:(void (^)())completion;


@end
