//
//  SPRatingsPromptView.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/18/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import "SPRatingsPromptView.h"
#import "UIDevice+Extensions.h"
#import "VSThemeManager.h"



#pragma mark ================================================================================
#pragma mark Constants
#pragma mark ================================================================================

static CGFloat SPRatingPromptViewWidthPhone             = 320.0f;
static CGFloat SPRatingPromptViewWidthPad               = 400.0f;
static CGFloat SPRatingPromptViewHeight                 = 105.0f;

static CGFloat SPRatingPromptSeparatorHeight            = 1.0f;
static UIEdgeInsets SPRatingPromptSeparatorCapInsets    = {1.0f, 0.0f, 0.0f, 0.0f};

static CGFloat SPRatingPromptLabelPaddingY              = 5.0;
static CGFloat SPRatingPromptButtonPaddingX             = 5.0f;


#pragma mark ================================================================================
#pragma mark SPRatingPromptView
#pragma mark ================================================================================

@interface SPRatingsPromptView ()
@property (nonatomic, strong) UIView *container;
@end


@implementation SPRatingsPromptView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, width, SPRatingPromptViewHeight)];
    if (self) {
        [self applySimplenoteLayout];
        [self applySimplenoteStyle];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleThemeDidChangeNote:)
                                                     name:VSThemeManagerThemeDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)applySimplenoteLayout
{
    NSAssert(self.container,    @"Container should be set");
    NSAssert(self.label,        @"Label should be set");
    NSAssert(self.leftButton,   @"Left Button should be set");
    NSAssert(self.rightButton,  @"Left Button should be set");
    
    CGFloat containerWidth          = [UIDevice isPad] ? SPRatingPromptViewWidthPad : SPRatingPromptViewWidthPhone;
    
    // Update Container's Width
    CGRect containerFrame           = self.container.frame;
    containerFrame.size.width       = containerWidth;
    containerFrame.origin.x         = (CGRectGetWidth(self.bounds) - containerWidth) * 0.5f;
    self.container.frame            = CGRectIntegral(containerFrame);
    
    // Update Label's Width
    CGRect labelFrame               = self.label.frame;
    labelFrame.size.width           = containerWidth;
    self.label.frame                = labelFrame;
    
    // Update Left Button's Position
    CGRect leftButtonFrame          = self.leftButton.frame;
    leftButtonFrame.origin.y        += SPRatingPromptLabelPaddingY;
    leftButtonFrame.origin.x        = CGRectGetMidX(self.container.bounds) - CGRectGetWidth(leftButtonFrame) - SPRatingPromptButtonPaddingX;
    self.leftButton.frame           = leftButtonFrame;
    
    CGRect rightButtonFrame         = self.rightButton.frame;
    rightButtonFrame.origin.y       += SPRatingPromptLabelPaddingY;
    rightButtonFrame.origin.x       = CGRectGetMidX(self.container.bounds) + SPRatingPromptButtonPaddingX;
    self.rightButton.frame          = rightButtonFrame;
}

- (void)applySimplenoteStyle
{
    VSTheme *theme                  = [[VSThemeManager sharedManager] theme];
    
    self.backgroundColor            = [UIColor clearColor];
    
    // Update Label Style
    self.label.font                 = [theme fontForKey:@"ratingsTitleFont"];
    self.label.textColor            = [theme colorForKey:@"noteHeadlineFontColor"];
    
    // Update Buttons Style
    UIColor *buttonColor            = [theme colorForKey:@"tintColor"];
    UIFont *buttonFont              = [theme fontForKey:@"ratingsButtonFont"];
    
    for (UIButton *button in @[self.leftButton, self.rightButton]) {
        button.backgroundColor      = [UIColor clearColor];
        button.layer.borderWidth    = 1.0f;
        button.layer.borderColor    = buttonColor.CGColor;
        button.titleLabel.font      = buttonFont;
        [button setTitleColor:buttonColor forState:UIControlStateNormal];
    }
}


#pragma mark - Notification Helpers

- (void)handleThemeDidChangeNote:(NSNotification *)note
{
    [self applySimplenoteStyle];
    [self setNeedsDisplay];
}


#pragma mark - UIView Methods

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    VSTheme *theme                  = [[VSThemeManager sharedManager] theme];
    
    // Draw the Separator
    UIImage *shadowImage            = [theme imageForKey:@"navigationBarShadowImage"];
    shadowImage                     = [shadowImage resizableImageWithCapInsets:SPRatingPromptSeparatorCapInsets resizingMode:UIImageResizingModeTile];

    CGFloat borderThickness         = SPRatingPromptSeparatorHeight / [[UIScreen mainScreen] scale];
    CGRect borderFrame              = CGRectMake(0.0f, CGRectGetHeight(self.frame) - borderThickness, CGRectGetWidth(self.frame), borderThickness);
    [shadowImage drawInRect:borderFrame];
}

@end
