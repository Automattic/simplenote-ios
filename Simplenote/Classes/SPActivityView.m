//
//  TWEpisodeActionView.m
//  Podcasts
//
//  Created by Tom Witkin on 3/21/13.
//  Copyright (c) 2013 Tom Witkin. All rights reserved.
//

#import "SPActivityView.h"
#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"
#import "SPActionButton.h"
#import "Note.h"
#import "SPButton.h"
#import "SPSideBySideView.h"
#import "UIImage+Colorization.h"
#import "SPToggle.h"
#import "UIDevice+Extensions.h"


@interface SPActivityView ()

@end

@implementation SPActivityView

- (id<SPActivityViewDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id<SPActivityViewDelegate>)newDelegate
{
    delegate = newDelegate;
}

- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

+ (SPActivityView *)activityViewWithToggleTitles:(NSArray *)toggleTitles
                            toggleSelectedTitles:(NSArray *)toggleSelectedTitles
                              actionButtonImages:(NSArray *)actionButtonImages
                              actionButtonTitles:(NSArray *)actionButtonTitles
                                    buttonTitles:(NSArray *)buttonTitles
                                          status:(NSString *)status
                                        delegate:(id<SPActivityViewDelegate>)delegate {

    SPActivityView *actionView = [[SPActivityView alloc] initWithFrame:CGRectZero];
    
    [actionView setupViewWithToggleTitles:toggleTitles
                     toggleSelectedTitles:toggleSelectedTitles
                       actionButtonImages:actionButtonImages
                       actionButtonTitles:actionButtonTitles
                             buttonTitles:buttonTitles
                                   status:status];
    
    actionView.delegate = delegate;
    return actionView;
}

- (void)drawRect:(CGRect)rect {

    // draw borders
    CGFloat borderThickness = 1.0 / [[UIScreen mainScreen] scale];
    [[self.theme colorForKey:@"actionSheetDividerColor"] setFill];

    CGRect borderRect = CGRectMake(0, 0, self.frame.size.width, borderThickness);

    if (statusView) {
        borderRect.origin.y = CGRectGetMaxY(statusView.frame);
        [[UIBezierPath bezierPathWithRect:borderRect] fill];
    }

    if (toggleView) {
        borderRect.origin.y = CGRectGetMaxY(toggleView.frame);
        [[UIBezierPath bezierPathWithRect:borderRect] fill];
    }

    if (buttonView) {
        borderRect.origin.y = CGRectGetMaxY(actionScrollView.frame);
        [[UIBezierPath bezierPathWithRect:borderRect] fill];
    }
    
    if (buttonArray.count == 2) {
        CGRect buttonRect = CGRectMake(self.frame.size.width / 2.0,
                                           CGRectGetMaxY(actionScrollView.frame),
                                           borderThickness,
                                           buttonView.frame.size.height);
        
        [[UIBezierPath bezierPathWithRect:buttonRect] fill];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat toggleHeight = [self.theme floatForKey:@"actionViewToggleHeight"];
    CGFloat toggleWidth = [self.theme floatForKey:@"actionViewToggleWidth"];
    CGFloat sidePadding = [self.theme floatForKey:@"actionViewHorizontalPadding"];
    CGFloat width = self.frame.size.width + self.superview.frame.origin.x;
    CGFloat buttonHeight = [self.theme floatForKey:@"actionViewButtonHeight"];

    statusView.frame = CGRectMake(0, 0, width, toggleView.frame.size.height);

    statusLabel.frame = statusView.bounds;
    statusActivityIndicator.center = statusLabel.center;

    // place toggles
    toggleView.frame = CGRectMake(0, CGRectGetMaxY(statusView.frame), width, toggleView.frame.size.height);

    // center toggles in view
    NSInteger toggleCount = toggleArray.count;
    CGFloat totalToggleWidth = toggleCount * toggleWidth + sidePadding * (toggleCount - 1);

    for (int i = 0; i < toggleCount; i++) {
        SPButton *button = toggleArray[i];
        button.frame = CGRectIntegral(CGRectMake((width - totalToggleWidth) / 2.0 + i * (toggleWidth + sidePadding),
                                                 (toggleView.frame.size.height - toggleHeight) / 2.0,
                                                 button.frame.size.width,
                                                 button.frame.size.height));
    }

    CGFloat actionButtonHeight = [self.theme floatForKey:@"actionButtonHeight"];
    CGFloat actionButtonWidth = [self.theme floatForKey:@"actionButtonWidth"];

    actionScrollView.frame = CGRectMake(self.frame.origin.x,
                                        CGRectGetMaxY(toggleView.frame),
                                        width,
                                        actionScrollView.frame.size.height);
    
    // if all buttons will fit in view, center buttons rather then left align
    CGFloat actionButtonLeftInset = 0.0;
    CGFloat totalButtonWidth = 2 * sidePadding + (actionButtonWidth) * actionButtonArray.count;
    if (totalButtonWidth < actionScrollView.frame.size.width)
        actionButtonLeftInset = (actionScrollView.frame.size.width - totalButtonWidth) / 2.0;
    
    for (int i = 0; i < actionButtonArray.count; i ++) {
        
        SPActionButton *button = actionButtonArray[i];
        button.frame = CGRectIntegral(CGRectMake(actionButtonLeftInset + sidePadding + i * (actionButtonWidth),
                                                 (actionScrollView.frame.size.height - actionButtonHeight) / 2.0,
                                                 actionButtonWidth,
                                                 actionButtonHeight));
    }
    
    CGFloat contentWidth = actionButtonArray.count * (actionButtonWidth) + sidePadding;
    
    actionScrollView.contentSize = CGSizeMake(contentWidth,
                                              actionScrollView.frame.size.height);

    NSInteger buttonCount = buttonArray.count;
    BOOL showButtonsSideBySide = buttonCount == 2;
    for (int i = 0; i < buttonCount; i++) {
        
        SPButton *button = buttonArray[i];
        
        // even numbered buttons are on left and even numbered are on right
        
        BOOL evenButton = i % 2 == 0;
        
        button.frame = CGRectIntegral(CGRectMake((!evenButton && showButtonsSideBySide) ? width / 2.0 : 0.0,
                                                 showButtonsSideBySide ? (i / 2) * buttonHeight : i * buttonHeight,
                                                 showButtonsSideBySide ? width / 2.0 : width,
                                                 buttonHeight));
    }
    
    buttonView.frame = CGRectMake(0,
                                  CGRectGetMaxY(actionScrollView.frame),
                                  width,
                                  buttonView.frame.size.height);

}


- (void)setupViewWithToggleTitles:(NSArray *)toggleTitles toggleSelectedTitles:(NSArray *)toggleSelectedTitles
actionButtonImages:(NSArray *)actionButtonImages actionButtonTitles:(NSArray *)actionButtonTitles buttonTitles:(NSArray *)buttonTitles status:(NSString *)status {
    
    
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat toggleHeight = [self.theme floatForKey:@"actionViewToggleHeight"];
    CGFloat toggleWidth = [self.theme floatForKey:@"actionViewToggleWidth"];
    CGFloat toggleViewBaseHeight = [self.theme floatForKey:@"actionViewToggleViewBaseHeight"];
    CGFloat width = 320.0;
    CGFloat buttonHeight = [self.theme floatForKey:@"actionViewButtonHeight"];
    
    if (toggleTitles.count > 0 || status.length > 0) {
        
        // create toggles
        // toggle View
        toggleView = [[UIView alloc] initWithFrame:CGRectZero];
        toggleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:toggleView];
        
        toggleArray = [[NSMutableArray alloc] initWithCapacity:toggleTitles.count];
        
        UIImage *toggleBackground = [[[UIImage imageNamed:@"toggle_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *toggleBackgroundHighlighted = [[[UIImage imageNamed:@"toggle_background_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        for (int i = 0; i < toggleTitles.count; i++) {
            
            SPToggle *newToggle = [[SPToggle alloc] initWithFrame:CGRectMake(0, 0, toggleWidth, toggleHeight)];
            
            [newToggle setBackgroundImage:toggleBackground
                                 forState:UIControlStateNormal];
            [newToggle setBackgroundImage:toggleBackgroundHighlighted
                                 forState:UIControlStateHighlighted];
            newToggle.tintColor = [self.theme colorForKey:@"actionViewToggleTintColor"];
            [newToggle setTitle:toggleTitles[i] forState:UIControlStateNormal];
            [newToggle setTitle:toggleSelectedTitles[i] forState:UIControlStateHighlighted];
            [newToggle setTitleColor:[self.theme colorForKey:@"tintColor"]
                            forState:UIControlStateNormal];
            newToggle.titleLabel.font = [self.theme fontForKey:@"actionViewStatusFont"];
            
            [newToggle addTarget:self
                          action:@selector(toggleDidChangeValue:)
                forControlEvents:UIControlEventValueChanged];
            
            [toggleArray addObject:newToggle];
            [toggleView addSubview:newToggle];
        }

        statusView = [UIView new];
        statusView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:statusView];

        statusLabel = [[UILabel alloc] init];
        statusLabel.font = [self.theme fontForKey:@"actionViewStatusFont"];
        statusLabel.textColor = [self.theme colorForKey:@"actionViewStatusFontColor"];
        statusLabel.adjustsFontSizeToFitWidth = YES;
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.text = status;

        statusActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(self.theme.isDark ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray)];
        statusActivityIndicator.alpha = 0.0;
        [statusActivityIndicator hidesWhenStopped];
        
        [statusView addSubview:statusLabel];
        [statusView addSubview:statusActivityIndicator];
        
        CGFloat toggleViewHeight = (toggleArray.count > 0 ?  toggleViewBaseHeight : 0.0);
        toggleView.frame = CGRectMake(0, 0, width, toggleViewHeight);
    }
    
    // setup action view
    if (actionButtonImages.count > 0 && actionButtonImages.count == actionButtonTitles.count) {
        
        actionScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, 100)];
        actionScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        actionScrollView.alwaysBounceVertical = NO;
        actionScrollView.alwaysBounceHorizontal = YES;
        actionScrollView.showsHorizontalScrollIndicator = NO;
        
        [self addSubview:actionScrollView];
        CGFloat actionButtonHeight = [[[VSThemeManager sharedManager] theme] floatForKey:@"actionButtonHeight"];
        
        // create buttons
        NSInteger actionButtonCount = actionButtonImages.count;
        actionButtonArray = [NSMutableArray arrayWithCapacity:actionButtonCount];
        
        UIImage *actionButtonBackgroundImage = [[UIImage imageNamed:@"action_button_background"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *actionButtonBackgroundDisabledImage = [[[UIImage imageNamed:@"action_button_background"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] imageWithOverlayColor:[self.theme colorForKey:@"actionViewButtonDisabledColor"]];
        UIImage *actionButtonBackgroundHighlightImage = [[UIImage imageNamed:@"action_button_background_highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        for (int i = 0; i < actionButtonCount; i ++) {
            SPActionButton *button = [[SPActionButton alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      actionButtonHeight,
                                                                                      actionButtonHeight)];
            
            [actionScrollView addSubview:button];
            [actionButtonArray addObject:button];
            
            UIImage *buttonImage = (UIImage*)actionButtonImages[i];
            [button setImage:[buttonImage
                              imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                    forState:UIControlStateNormal];
            [button setImage:[[buttonImage imageWithOverlayColor:[self.theme colorForKey:@"actionViewButtonDisabledColor"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                    forState:UIControlStateDisabled];
            [button setImage:[[buttonImage imageWithOverlayColor:[self.theme colorForKey:@"backgroundColor"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                    forState:UIControlStateHighlighted];
            
            // add label
            [button setTitle:actionButtonTitles[i]
                    forState:UIControlStateNormal];
            [button setTitle:actionButtonTitles[i]
                    forState:UIControlStateHighlighted];
            [button setTitleColor:[self.theme colorForKey:@"tintColor"]
                         forState:UIControlStateNormal];
            [button setTitleColor:[self.theme colorForKey:@"actionViewButtonDisabledColor"]
                         forState:UIControlStateDisabled];
            
            [button setBackgroundImage:actionButtonBackgroundImage
                              forState:UIControlStateNormal];
            [button setBackgroundImage:actionButtonBackgroundDisabledImage
                              forState:UIControlStateDisabled];
            [button setBackgroundImage:actionButtonBackgroundHighlightImage
                              forState:UIControlStateHighlighted];
            
            [button addTarget:self
                       action:@selector(actionButtonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    // setup button view
    if (buttonTitles.count > 0) {
        buttonArray = [NSMutableArray arrayWithCapacity:buttonTitles.count];
        buttonView = [[UIView alloc] init];
        [self addSubview:buttonView];
        
        for (NSString *title in buttonTitles) {
            SPButton *newButton = [[SPButton alloc] init];
            
            [newButton setTitle:title forState:UIControlStateNormal];
            [newButton setTitleColor:[self.theme colorForKey:@"tintColor"]
                            forState:UIControlStateNormal];
            [newButton setTitleColor:[self.theme colorForKey:@"backgroundColor"]
                            forState:UIControlStateHighlighted];
            [newButton setTitleColor:[self.theme colorForKey:@"actionViewButtonDisabledColor"]
                            forState:UIControlStateDisabled];
            
            newButton.backgroundHighlightColor = [self.theme colorForKey:@"tintColor"];
            
            newButton.titleLabel.font = [self.theme fontForKey:@"actionButtonFont"];
            newButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
            
            [newButton addTarget:self
                          action:@selector(buttonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
            [buttonArray addObject:newButton];
            [buttonView addSubview:newButton];
        }
        
        // size button view based on
        NSInteger numButtonRows = buttonTitles.count == 2 ? 1 : buttonTitles.count;
        buttonView.frame = CGRectMake(0, 0, width, numButtonRows * buttonHeight);
    }
    
    [self layoutSubviews];

    self.frame = CGRectMake(0, 0, width, CGRectGetMaxY(buttonView.frame));
}

- (void)setToggleState:(BOOL)enabled atIndex:(NSInteger)index {

    if (toggleArray.count > index) {

        SPToggle *toggle = toggleArray[index];
        [toggle setOn:enabled];
    }
}

- (void)showActivityIndicator {
    
    [self setActivityIndicatorHidden:NO];
}
    
- (void)hideActivityIndicator {
    
    [self setActivityIndicatorHidden:YES];
}

- (void)setActivityIndicatorHidden:(BOOL)hidden {
    
    if (!hidden)
        [statusActivityIndicator startAnimating];
    
    
    [UIView animateWithDuration:0.15
                     animations:^{
                         
                         if (hidden)
                            statusActivityIndicator.alpha = 0.0;
                         else
                            statusLabel.alpha = 0.0;
                         
                     }];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         if (!hidden)
                            statusActivityIndicator.alpha = 1.0;
                         else
                            statusLabel.alpha = 1.0;
                         
                     } completion:^(BOOL finished) {
                         
                         if (hidden)
                            [statusActivityIndicator stopAnimating];
                         
                     }];
    

}

- (void)setButtonImage:(UIImage *)image atIndex:(NSInteger)index {
    
    SPButton *button = (SPButton *)[self buttonAtIndex:index];
    
    [button setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
            forState:UIControlStateNormal];
    [button setImage:[image imageWithOverlayColor:[self.theme colorForKey:@"actionViewButtonDisabledColor"]]
            forState:UIControlStateDisabled];
    [button setImage:[image imageWithOverlayColor:[self.theme colorForKey:@"backgroundColor"]]
            forState:UIControlStateHighlighted];
}


#pragma mark button actions

- (void)actionButtonTapped:(id)sender {
    
    NSInteger index = [actionButtonArray indexOfObject:sender];
    if ([delegate respondsToSelector:@selector(activityView:didSelectActionAtIndex:)])
        [delegate activityView:self didSelectActionAtIndex:index];
    
    
}

- (void)buttonTapped:(id)sender {
    
    NSInteger index = [buttonArray indexOfObject:sender];
    if ([delegate respondsToSelector:@selector(activityView:didSelectButtonAtIndex:)])
        [delegate activityView:self didSelectButtonAtIndex:index];
    
}

- (void)toggleDidChangeValue:(id)sender {
    
    NSInteger index = [toggleArray indexOfObject:sender];
    if ([delegate respondsToSelector:@selector(activityView:didToggleIndex:enabled:)])
        [delegate activityView:self didToggleIndex:index enabled:[(SPToggle *)sender isOn]];
    
}

#pragma mark access UI controls

- (UIButton *)toggleAtIndex:(NSInteger)index {
    
    if (toggleArray.count > index)
        return toggleArray[index];
    else
        return nil;
}

- (UIButton *)actionButtonAtIndex:(NSInteger)index {
    
    if (actionButtonArray.count > index)
        return actionButtonArray[index];
    else
        return nil;
}

- (UIButton *)buttonAtIndex:(NSInteger)index {
    
    if (buttonArray.count > index)
        return buttonArray[index];
    else
        return nil;
}


@end
