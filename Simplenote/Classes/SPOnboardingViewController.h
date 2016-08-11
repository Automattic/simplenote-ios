//
//  TWOnboardingViewController.h
//  Onboarding
//
//  Created by Tom Witkin on 9/11/13.
//  Copyright (c) 2013 Tom Witkin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPButton;

@interface SPOnboardingViewController : UIViewController <UIScrollViewDelegate> {
    
    UIScrollView *contentScrollView;
    UIScrollView *secondaryScrollView;
    UIScrollView *backgroundScrollView;
    NSMutableArray *backgroundImageViews;
    
    NSMutableArray *contentViewArray;
    NSMutableArray *secondaryViewArray;
    
    UIPageControl *pageControl;
    SPButton *getStartedButton;
}

extern NSString * const SPOnboardingDidFinish;

@end
