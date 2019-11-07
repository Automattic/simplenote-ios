//
//  TWEpisodeActionView.m
//  Podcasts
//
//  Created by Tom Witkin on 3/21/13.
//  Copyright (c) 2013 Tom Witkin. All rights reserved.
//

#import "SPActivityView.h"
#import "VSThemeManager.h"
#import "SPActionButton.h"
#import "Note.h"
#import "SPButton.h"
#import "SPSideBySideView.h"
#import "UIImage+Colorization.h"
#import "SPToggle.h"
#import "UIDevice+Extensions.h"
#import "Simplenote-Swift.h"


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
    [[UIColor simplenoteDividerColor] setFill];

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
        UIColor *toggleTintColor = [UIColor simplenoteLightBlueColor];
        UIColor *toggleTitleColor = [UIColor simplenoteTintColor];

        for (int i = 0; i < toggleTitles.count; i++) {
            
            SPToggle *newToggle = [[SPToggle alloc] initWithFrame:CGRectMake(0, 0, toggleWidth, toggleHeight)];
            
            [newToggle setBackgroundImage:toggleBackground
                                 forState:UIControlStateNormal];
            [newToggle setBackgroundImage:toggleBackgroundHighlighted
                                 forState:UIControlStateHighlighted];
            newToggle.tintColor = toggleTintColor;
            [newToggle setTitle:toggleTitles[i] forState:UIControlStateNormal];
            [newToggle setTitle:toggleSelectedTitles[i] forState:UIControlStateHighlighted];
            [newToggle setTitleColor:toggleTitleColor forState:UIControlStateNormal];
            newToggle.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
            
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
        statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        statusLabel.textColor = [UIColor colorWithName:UIColorNameActionViewStatusFontColor];
        statusLabel.adjustsFontSizeToFitWidth = YES;
        statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        statusLabel.textAlignment = NSTextAlignmentCenter;
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.text = status;

        statusActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(SPUserInterface.isDark ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray)];
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
        
        UIColor *actionButtonBackgroundColor = [UIColor simplenoteBackgroundColor];
        UIColor *actionButtonBackgroundDisabledColor = [UIColor colorWithName:UIColorNameActionViewButtonDisabledColor];
        UIImage *actionButtonBackgroundImage = [[UIImage imageNamed:@"action_button_background"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *actionButtonBackgroundDisabledImage = [[[UIImage imageNamed:@"action_button_background"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] imageWithOverlayColor:actionButtonBackgroundDisabledColor];
        UIImage *actionButtonBackgroundHighlightImage = [[UIImage imageNamed:@"action_button_background_highlighted"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIColor *actionButtonTitleColorNormal = [UIColor simplenoteTintColor];

        for (int i = 0; i < actionButtonCount; i ++) {
            SPActionButton *button = [[SPActionButton alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      actionButtonHeight,
                                                                                      actionButtonHeight)];
            
            [actionScrollView addSubview:button];
            [actionButtonArray addObject:button];
            
            UIImage *buttonImage = (UIImage*)actionButtonImages[i];
            [button setImage:[buttonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                    forState:UIControlStateNormal];
            [button setImage:[[buttonImage imageWithOverlayColor:actionButtonBackgroundDisabledColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                    forState:UIControlStateDisabled];
            [button setImage:[[buttonImage imageWithOverlayColor:actionButtonBackgroundColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                    forState:UIControlStateHighlighted];
            
            // add label
            [button setTitle:actionButtonTitles[i] forState:UIControlStateNormal];
            [button setTitle:actionButtonTitles[i] forState:UIControlStateHighlighted];
            [button setTitleColor:actionButtonTitleColorNormal forState:UIControlStateNormal];
            [button setTitleColor:actionButtonBackgroundDisabledColor forState:UIControlStateDisabled];
            
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

        UIColor *tintColor = [UIColor simplenoteTintColor];
        UIColor *backgroundColor = [UIColor simplenoteBackgroundColor];
        UIColor *disabledColor = [UIColor colorWithName:UIColorNameActionViewButtonDisabledColor];

        for (NSString *title in buttonTitles) {
            SPButton *newButton = [SPButton new];
            
            [newButton setTitle:title forState:UIControlStateNormal];
            [newButton setTitleColor:tintColor forState:UIControlStateNormal];
            [newButton setTitleColor:backgroundColor forState:UIControlStateHighlighted];
            [newButton setTitleColor:disabledColor forState:UIControlStateDisabled];
            
            newButton.backgroundHighlightColor = tintColor;
            
            newButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
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
                             self->statusActivityIndicator.alpha = 0.0;
                         else
                             self->statusLabel.alpha = 0.0;
                         
                     }];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         if (!hidden)
                             self->statusActivityIndicator.alpha = 1.0;
                         else
                             self->statusLabel.alpha = 1.0;
                         
                     } completion:^(BOOL finished) {
                         
                         if (hidden)
                             [self->statusActivityIndicator stopAnimating];
                         
                     }];
    

}

- (void)refreshButtonImages
{
    UIColor *actionButtonBackgroundColor = [UIColor simplenoteBackgroundColor];
    UIColor *actionButtonBackgroundDisabledColor = [UIColor colorWithName:UIColorNameActionViewButtonDisabledColor];

    for (SPActionButton *button in actionButtonArray) {
        UIImage *disabledImage = [[button imageForState:UIControlStateDisabled] imageWithOverlayColor:actionButtonBackgroundDisabledColor];
        UIImage *highligtedImage = [[button imageForState:UIControlStateHighlighted] imageWithOverlayColor:actionButtonBackgroundColor];

        [button setImage:disabledImage forState:UIControlStateDisabled];
        [button setImage:highligtedImage forState:UIControlStateHighlighted];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

    if (@available(iOS 13.0, *)) {
        if ([previousTraitCollection hasDifferentColorAppearanceComparedToTraitCollection:self.traitCollection] == false) {
            return;
        }

        [self refreshButtonImages];
    }
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
