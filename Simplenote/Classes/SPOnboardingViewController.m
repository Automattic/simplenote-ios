//
//  TWOnboardingViewController.m
//  Onboarding
//
//  Created by Tom Witkin on 9/11/13.
//  Copyright (c) 2013 Tom Witkin. All rights reserved.
//

#import "SPOnboardingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SPButton.h"
#import "UIDevice+Extensions.h"


NSString * const SPOnboardingDidFinish = @"SPOnboardDidFinish";

@interface SPOnboardingViewController ()

@end

@implementation SPOnboardingViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [UIDevice isPad] ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}
- (void)viewDidLayoutSubviews {
    
    CGFloat backgroundScrollViewWidth = self.view.bounds.size.width + 100;
    backgroundScrollView.contentSize = CGSizeMake(backgroundScrollViewWidth, self.view.bounds.size.height);
    
    CGFloat bottomBuffer = 44.0;
    CGFloat scrollViewHeight = self.view.bounds.size.height - bottomBuffer;
    CGFloat scrollViewWidth = self.view.bounds.size.width;
    CGFloat secondaryScrollViewWidth = self.view.bounds.size.width + 100;
    contentScrollView.contentSize = CGSizeMake(scrollViewWidth * 4.0, scrollViewHeight);
    secondaryScrollView.contentSize = CGSizeMake(secondaryScrollViewWidth * 4.0, scrollViewHeight);
    
    
    CGFloat padding = 20.0;
    for (int i = 0; i < contentViewArray.count; i++) {
        
        UILabel *titleLabel = contentViewArray[i];
        UILabel *textLabel = secondaryViewArray[i];
        
        CGFloat labelWidth = MIN(self.view.bounds.size.width - 2.0 * padding, 400);
        CGFloat titleLabelHeight = [titleLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)].height;
        CGFloat textLabelHeight = [textLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)].height;
        CGFloat totalLabelHeight = titleLabelHeight + padding + textLabelHeight;
        
        titleLabel.frame = CGRectMake((self.view.bounds.size.width - labelWidth) / 2.0 + self.view.bounds.size.width * i,
                                      (contentScrollView.frame.size.height - totalLabelHeight) / 2.0,
                                      labelWidth,
                                      titleLabelHeight);
        [contentScrollView addSubview:titleLabel];
        
        textLabel.frame = CGRectMake((secondaryScrollViewWidth - scrollViewWidth) / 2.0 + (self.view.bounds.size.width - labelWidth) / 2.0 + secondaryScrollViewWidth * i,
                                     titleLabel.frame.size.height + titleLabel.frame.origin.y + padding,
                                     labelWidth,
                                     textLabelHeight);
        [secondaryScrollView addSubview:textLabel];
        
    }
    

    // add motion effects
    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"frame.origin.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = [NSNumber numberWithInt:-20];
    horizontalEffect.maximumRelativeValue = [NSNumber numberWithInt:20];
    [secondaryScrollView addMotionEffect:horizontalEffect];
    
    UIInterpolatingMotionEffect *horizontalEffectTwo = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"frame.origin.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffectTwo.minimumRelativeValue = [NSNumber numberWithInt:-10];
    horizontalEffectTwo.maximumRelativeValue = [NSNumber numberWithInt:10];
    [contentScrollView addMotionEffect:horizontalEffectTwo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIColor *blueColor = [UIColor colorWithRed:68.0 / 255.0
                                         green:138.0 / 255.0
                                          blue:201.0 / 255.0
                                         alpha:1.0];
    
    self.view.backgroundColor = blueColor;
    
    backgroundScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    backgroundScrollView.showsHorizontalScrollIndicator = NO;
    backgroundScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundScrollView.userInteractionEnabled = NO;
    [self.view addSubview:backgroundScrollView];
    
    // setup background images
    NSArray *images = @[[[UIImage imageNamed:@"feature-everywhere"] imageWithRenderingMode:             UIImageRenderingModeAlwaysTemplate],
                        [[UIImage imageNamed:@"feature-free"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                        [[UIImage imageNamed:@"feature-organize"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                        [[UIImage imageNamed:@"feature-search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                        [[UIImage imageNamed:@"feature-share"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate],
                        [[UIImage imageNamed:@"feature-time"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    
    CGFloat yOrigin = -10;
    CGFloat sizeAdjustment = [UIDevice isPad] ? 1.5 : 1.0;
    CGFloat itemSpacing = 48 * sizeAdjustment * sizeAdjustment;
    CGFloat xOrigin = 20;
    backgroundImageViews = [NSMutableArray arrayWithCapacity:25];
    int i = 0;
    int row = 0;
    
    UIColor *imageTintColor = [UIColor colorWithRed:64.0 / 255.0
                                              green:131.0 / 255.0
                                               blue:189.0 / 255.0
                                              alpha:1.0];
    
    CGFloat backgroundScrollViewWidth = MAX(self.view.bounds.size.width, self.view.bounds.size.height) + 100;

    while (yOrigin < self.view.bounds.size.height) {
        
        while (xOrigin < backgroundScrollViewWidth) {
            
            if (i >= images.count)
                i = 0;
            
            UIImage *image = images[i];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.tintColor = imageTintColor;
            
            imageView.frame = CGRectMake(xOrigin, yOrigin, image.size.width * sizeAdjustment, image.size.height * sizeAdjustment);
            
            [backgroundScrollView addSubview:imageView];
            
            [backgroundImageViews addObject:imageView];
            
            // pulse view
            
            CABasicAnimation *opacityAnimation;
            opacityAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.duration = 2.0 + ((row * i) % 3) * 1.2;
            opacityAnimation.repeatCount=HUGE_VALF;
            opacityAnimation.autoreverses=YES;
            opacityAnimation.fromValue=[NSNumber numberWithFloat:1.0];
            opacityAnimation.toValue=[NSNumber numberWithFloat:0.3];
            [imageView.layer addAnimation:opacityAnimation forKey:@"animateOpacity"]; //myButton.layer instead of
            
            i++;
            xOrigin += itemSpacing + image.size.width;
        }
        
        row++;
        
        xOrigin = 30 - 44 * (row % 2);
        yOrigin += itemSpacing + 44;
        
    }
    
    CGFloat bottomBuffer = 44.0;
    CGFloat scrollViewHeight = self.view.bounds.size.height - bottomBuffer;
    CGFloat scrollViewWidth = self.view.bounds.size.width;
    CGFloat secondaryScrollViewWidth = self.view.bounds.size.width + 100;
    
    contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       scrollViewWidth,
                                                                       scrollViewHeight)];
    contentScrollView.alwaysBounceHorizontal = YES;
    contentScrollView.delegate = self;
    contentScrollView.pagingEnabled = YES;
    contentScrollView.showsHorizontalScrollIndicator = NO;
    contentScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:contentScrollView];
    
    secondaryScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake((scrollViewWidth - secondaryScrollViewWidth) / 2.0,
                                                                         0,
                                                                         secondaryScrollViewWidth,
                                                                         scrollViewHeight)];
    secondaryScrollView.showsHorizontalScrollIndicator = NO;
    secondaryScrollView.userInteractionEnabled = NO;
    secondaryScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:secondaryScrollView belowSubview:contentScrollView];
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = 4;
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [pageControl sizeToFit];
    pageControl.frame = CGRectMake((self.view.bounds.size.width - pageControl.frame.size.width) / 2.0,
                                   scrollViewHeight + (bottomBuffer - pageControl.frame.size.height) / 2.0,
                                   pageControl.frame.size.width,
                                   pageControl.frame.size.height);
    pageControl.currentPage = 0;
    [pageControl addTarget:self
                    action:@selector(pageControlDidChangeValue:)
          forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];
    
    
    UIFont *titleFont = [UIFont systemFontOfSize:([UIDevice isPad] ? 52.0 : 36.0)];
    UIFont *bodyFont = [UIFont systemFontOfSize:([UIDevice isPad] ? 26.0 : 18.0)];
    
    
    
    NSArray *featureTitles = @[NSLocalizedString(@"Welcome to Simplenote", @"Message shown in first launch view"),
                               NSLocalizedString(@"Use it everywhere", @"Message shown in first launch view"),
                               NSLocalizedString(@"Work together", @"Message shown in first launch view"),
                               NSLocalizedString(@"Stay organized", @"Message shown in first launch view")];
    NSArray *featureText = @[@" ",
                             NSLocalizedString(@"Your notes stay updated across all your devices. No buttons to press. It just works.", @"Description of Simplenote shown in first launch view"),
                             NSLocalizedString(@"Share a list, post some instructions, or publish your thoughts.", @"Description of Simplenote shown in first launch view"),
                             NSLocalizedString(@"Find notes quickly with instant searching and simple tags.", @"Description of Simplenote shown in first launch view")];

    contentViewArray = [NSMutableArray arrayWithCapacity:featureTitles.count];
    secondaryViewArray = [NSMutableArray arrayWithCapacity:featureText.count];
    
    for (int i = 0; i < featureTitles.count; i++) {
        
        NSString *title = featureTitles[i];
        NSString *text = featureText[i];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        UILabel *textLabel = [[UILabel alloc] init];

        
        titleLabel.font = titleFont;
        titleLabel.text = title;
        titleLabel.numberOfLines = 0;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        [contentViewArray addObject:titleLabel];
        
        textLabel.font = bodyFont;
        textLabel.text = text;
        textLabel.numberOfLines = 0;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor whiteColor];
        [secondaryViewArray addObject:textLabel];
        
        [contentScrollView addSubview:titleLabel];
        [secondaryScrollView addSubview:textLabel];
    }
    
    
    getStartedButton = [[SPButton alloc] init];
    getStartedButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [getStartedButton setTitle:NSLocalizedString(@"Get Started", @"Button label shown on first launch screen to start the log in process")
                      forState:UIControlStateNormal];
    CGFloat buttonWidth = MIN(self.view.bounds.size.width, 400.0);
    getStartedButton.frame = CGRectMake((self.view.bounds.size.width - buttonWidth) / 2.0,
                                        scrollViewHeight - 44.0,
                                        buttonWidth,
                                        44.0);
    getStartedButton.backgroundColor = [UIColor whiteColor];
    getStartedButton.backgroundHighlightColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [getStartedButton setTitleColor:blueColor forState:UIControlStateNormal];
    getStartedButton.titleLabel.font = [UIFont systemFontOfSize:21.0];
    [getStartedButton addTarget:self action:@selector(getStartedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getStartedButton];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

 - (void)pageControlDidChangeValue:(id)sender {
     
     [contentScrollView setContentOffset:CGPointMake(pageControl.currentPage * contentScrollView.bounds.size.width, 0)
                                animated:YES];
 }

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat percentScrolled = contentScrollView.contentOffset.x / contentScrollView.contentSize.width;
    [secondaryScrollView setContentOffset:CGPointMake(percentScrolled * secondaryScrollView.contentSize.width, 0)];
    [backgroundScrollView setContentOffset:CGPointMake(percentScrolled * backgroundScrollView.contentSize.width / 8.0, 0)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    pageControl.currentPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self->contentScrollView.contentOffset = CGPointMake(self->contentScrollView.frame.size.width * self->pageControl.currentPage, 0);
    } completion:nil];
}

- (void)getStartedButtonAction:(id)sender {
    [UIView animateWithDuration:0.25 animations:^{
        
        self.view.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SPOnboardingDidFinish object:self];
        
    }];
}


@end
