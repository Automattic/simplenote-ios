
#import "SPActionSheet.h"
#import <QuartzCore/QuartzCore.h>
#import "VSThemeManager.h"
#import "SPButton.h"
#import "SPSideBySideView.h"
#import "Simplenote-Swift.h"


#pragma mark - Implementation

static CGFloat SPActionSheetCancelButtonIndexNone = -1;

@implementation SPActionSheet

@synthesize subviewsArray;
@synthesize contentView;
@synthesize titleView;

#pragma mark - Static Methods

+ (SPActionSheet *)showActionSheetInView:(UIView *)view
                             withMessage:(NSString *)message
                    withContentViewArray:(NSArray *)viewArray
                    withButtonTitleArray:(NSArray *)titleArray
                                delegate:(id<SPActionSheetDelegate>)delegate {
    
    
    SPActionSheet *actionSheet = [[SPActionSheet alloc] initWithFrame:CGRectZero];
    actionSheet.tapToDismiss = YES;
    actionSheet.cancelButtonIndex = SPActionSheetCancelButtonIndexNone;
    actionSheet.showPadding = NO;
    [actionSheet showInView:view
                  withMessage:message
              withViewArray:viewArray
            withStringArray:titleArray];
    actionSheet.delegate = delegate;
    return actionSheet;
    
    
}



+ (SPActionSheet *)showActionSheetWithActivityIndicatorInView:(UIView *)view
                                                     withMessage:(NSString *)message
                                                     delegate:(id<SPActionSheetDelegate>)delegate {
    
    SPActionSheet *actionSheet = [[SPActionSheet alloc] initWithFrame:CGRectZero];
    actionSheet.showPadding = YES;
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityView startAnimating];
    
    [actionSheet showInView:view
                withMessage:message
              withViewArray:@[activityView]
            withStringArray:nil];

    actionSheet.delegate = delegate;
    return actionSheet;
    
    
}

- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}


#pragma mark - View Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        self.titleView = nil;
        self.contentView = nil;
        
        showDividerRects = [self.theme boolForKey:@"actionSheetShowViewSeparators"];

    }
    return self;
}


- (id<SPActionSheetDelegate>)delegate
{
    return delegate;
}
- (void)setDelegate:(id<SPActionSheetDelegate>)newDelegate
{
    delegate = newDelegate;
}

#pragma mark - Display methods

- (CGSize) screenSize
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}



- (NSArray *)createButtonsFromStrings:(NSArray *)stringArray {
    
    NSMutableArray *labelArray = [[NSMutableArray alloc] initWithCapacity:stringArray.count];

    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    CGFloat labelPadding = [self.theme floatForKey:@"actionSheetLabelPadding"];
    
    for (NSString *string in stringArray) {
        CGSize textSize = [string sizeWithAttributes:@{NSFontAttributeName : font}];
        SPButton *textButton = [[SPButton alloc] initWithFrame:CGRectMake(0, 0, textSize.width + labelPadding, [self.theme floatForKey:@"actionSheetButtonHeight"])];

        textButton.backgroundHighlightColor = [UIColor simplenoteDividerColor];
        textButton.titleLabel.font = font;
        textButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        textButton.titleLabel.textColor = [UIColor simplenoteTextColor];
        [textButton setTitle:string forState:UIControlStateNormal];
        
        [textButton setTitleColor:[UIColor simplenoteTintColor]
                         forState:UIControlStateNormal];

        [textButton addTarget:self
                       action:@selector(didTapButton:)
             forControlEvents:UIControlEventTouchUpInside];
        
        textButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        [labelArray addObject:textButton];
    }
    
    buttonArray = [NSArray arrayWithArray:labelArray];
    
    if (labelArray.count == 2) {
        
        SPButton *buttonOne = labelArray[0];
        SPButton *buttonTwo = labelArray[1];
        
        return @[[[SPSideBySideView alloc] initWithFirstView:buttonOne secondView:buttonTwo]];
        
    } else
        return labelArray;
    
}


- (void)showInView:(UIView *)view
       withMessage:(NSString *)message
     withViewArray:(NSArray *)cViewArray
   withStringArray:(NSArray *)stringArray
{

    mainWindow = [[UIApplication sharedApplication] keyWindow];
    
    NSMutableArray *viewArray = [NSMutableArray arrayWithArray:cViewArray];
    
    [viewArray addObjectsFromArray:[self createButtonsFromStrings:stringArray]];
    
    [self showInView:view withMessage:message withViewArray:viewArray];
}






- (void)showInView:(UIView *)view withMessage:(NSString *)message withViewArray:(NSArray *)viewArray
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainWindow.bounds.size.width, 0)];
    
    
    //Create a label for the title text.
    CGSize titleSize = CGSizeZero;;
    UILabel *titleLabel;
    
    if (message) {
        NSDictionary *titleAttributes = @{
            NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline],
            NSForegroundColorAttributeName: [UIColor simplenoteTextColor]
        };
        NSAttributedString *titleAttributedString = [[NSAttributedString alloc] initWithString:message
                                                                                    attributes:titleAttributes];
        titleSize = [titleAttributedString boundingRectWithSize:CGSizeMake([self.theme floatForKey:@"actionSheetMaxTitleWidth"], [self.theme floatForKey:@"actionSheetMaxTitleHeight"])
                                              options:NSStringDrawingTruncatesLastVisibleLine
                                              context:nil].size;
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, titleSize.width, titleSize.height)];
        titleLabel.numberOfLines = 0;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.attributedText = titleAttributedString;
    }
    
    //Make sure that the title's label will have non-zero height.  If it has zero height, then we don't allocate any space
    //for it in the positioning of the views.
    float titleHeightOffset = (titleSize.height > 0.f ? [self.theme floatForKey:@"actionSheetBoxPadding"] : 0.f);
    
    float totalHeight;
    if (self.showPadding)
        
        totalHeight = titleSize.height + titleHeightOffset + [self.theme floatForKey:@"actionSheetBoxPadding"];
    
    else
        
        totalHeight = titleSize.height + titleHeightOffset;
    
    float totalWidth = mainWindow.bounds.size.width;
    
    
    int i = 0;
    
    //Position each view the first time, and identify which view has the largest width that controls
    //the sizing of the popover.
    for (UIView *view in viewArray) {
        
        view.frame = CGRectMake(0, totalHeight, view.frame.size.width, view.frame.size.height);
        view.clipsToBounds = YES;
        
        //Only add padding below the view if it's not the last item.
        float padding;
        if (self.showPadding)
        
            padding = (i == viewArray.count-1) ? 0.f : [self.theme floatForKey:@"actionSheetBoxPadding"];
        
        else
            
            padding = (i == viewArray.count-1) ? 0.f : 0;

        
        totalHeight += view.frame.size.height + padding;
        
        
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        
        [container addSubview:view];
        
        i++;
        
    }
    
    
    //If dividers are enabled, then we allocate the divider rect array.  This will hold NSValues
    if ([self.theme boolForKey:@"actionSheetShowViewSeparators"]) {
        dividerRects = [[NSMutableArray alloc] initWithCapacity:viewArray.count-1];
    }
    
    i = 0;
    
    for (UIView *view in viewArray) {
        
        if ([view autoresizingMask] == UIViewAutoresizingFlexibleWidth) {
            //Now make sure all flexible views are the full width
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, totalWidth, view.frame.size.height);
            
        } else {
            //If the view is not flexible width, then we position it centered in the view
            //without stretching it.
            view.frame = CGRectMake(0,
                                    view.frame.origin.y,
                                    totalWidth,
                                    view.frame.size.height);
        }
        
        CGFloat motionEffectDistance = [self.theme floatForKey:@"actionSheetMotionEffectMoveDistance"];

        //and if dividers are enabled, we record their position for the drawing methods
        if ([self.theme boolForKey:@"actionSheetShowViewSeparators"] && i != viewArray.count-1) {
            
            // the rect is hacked to work in both orientations of the device, which is why
            // the width is set to the max dimension as it does not resize
            CGFloat borderWidth = 1.0 / [[UIScreen mainScreen] scale];
            CGRect dividerRect = CGRectMake(view.frame.origin.x,
                                            floorf(view.frame.origin.y + view.frame.size.height + [self.theme floatForKey:@"actionSheetBoxPadding"] / 2.0),
                                            MAX(mainWindow.frame.size.height, mainWindow.frame.size.width),
                                            borderWidth);
            
            [((NSMutableArray *)dividerRects) addObject:[NSValue valueWithCGRect:dividerRect]];
            
            dividerRect.origin.y -= [self.theme floatForKey:@"actionSheetBoxPadding"] / 2.0;;
            dividerRect.size.width += 2 * motionEffectDistance;

            UIView *divider = [[UIView alloc] initWithFrame:dividerRect];
            divider.backgroundColor = [UIColor simplenoteDividerColor];
            [container addSubview:divider];
        }
        
        i++;
    }
    
    titleLabel.frame = CGRectMake(floorf(totalWidth*0.5f - titleSize.width*0.5f), 0, titleSize.width, titleSize.height);
    
    //Store the titleView as an instance variable if it is larger than 0 height (not an empty string)
    if (titleSize.height > 0) {
        self.titleView = titleLabel;
    }
    
    
    [container addSubview:titleLabel];
    
    
    container.frame = CGRectMake(0, 0, totalWidth, totalHeight);
    
    container.backgroundColor = [UIColor simplenoteTableViewBackgroundColor];
    
    self.subviewsArray = viewArray;
    
    [self showInView:view withContentView:container];
}


- (void)showInView:(UIView *)view withContentView:(UIView *)cView {
    
    // watch base view frame
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.contentView = cView;
    parentView = view;
    
    self.contentView.clipsToBounds = YES;
    
    [self setupLayoutInView:view];
    
    self.contentView.transform = CGAffineTransformMakeTranslation(0, contentView.bounds.size.height);
    
    // change the tint mode of the parent view
    parentView.tintAdjustmentMode  = UIViewTintAdjustmentModeDimmed;;
    self.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    
    [UIView animateWithDuration:[self.theme floatForKey:@"actionSheetPresentationTime"]
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:2.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         self.contentView.transform = CGAffineTransformIdentity;
                         self.backgroundColor = [UIColor colorWithWhite:0.0
                                                                  alpha:[self.theme floatForKey:@"actionSheetDimmingViewOpacity"]];
                         
                     } completion:^(BOOL finished) {
                         
                         if (self->delegate && [self->delegate respondsToSelector:@selector(actionSheetDidShow:)])
                             [self->delegate actionSheetDidShow:self];
                     }];
    

}




- (void)layoutInView:(UIView *)view
{
    // make transparent
    self.alpha = 0.f;
    
    [self setupLayoutInView:view];
    
    // animate back to full opacity
    [UIView animateWithDuration:0.1f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.alpha = 1.f;
                         
                     } completion:nil];
}

-(void)setupLayoutInView:(UIView*)view
{
    
    CGRect topViewBounds = mainWindow.bounds;

    CGFloat moveDistance = [self.theme floatForKey:@"actionSheetMotionEffectMoveDistance"];

    float contentHeight = contentView.frame.size.height;
    float contentWidth = contentView.frame.size.width;

    float padding;
    if (_showPadding)
        padding = [self.theme floatForKey:@"actionSheetBoxPadding"];
    else
        padding = 0;
    
    float boxHeight = contentHeight + 2.f*padding;
    float boxWidth = topViewBounds.size.width;

    float xOrigin = 0;
    float yOrigin = topViewBounds.size.height - boxHeight;

    boxFrame = CGRectMake(xOrigin, yOrigin, boxWidth, boxHeight);

    CGRect contentFrame = CGRectMake(boxFrame.origin.x + padding - moveDistance,
                                     boxFrame.origin.y + padding,
                                     contentWidth + 2 * moveDistance,
                                     contentHeight + moveDistance);

    contentFrame.origin.y -= view.safeAreaInsets.bottom;
    contentFrame.size.height += view.safeAreaInsets.bottom;

    contentView.frame = contentFrame;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    self.frame = topViewBounds;
    [self setNeedsDisplay];

    [self addSubview:contentView];
    [mainWindow addSubview:self];

    self.userInteractionEnabled = YES;
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                         action:@selector(panned:)];
    [contentView.superview addGestureRecognizer:panGesture];
    panGesture.enabled = _swipeToDismiss;
    
    // add motion effects
    
    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"frame.origin.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = [NSNumber numberWithInt:-moveDistance];
    horizontalEffect.maximumRelativeValue = [NSNumber numberWithInt:moveDistance];
    [contentView addMotionEffect:horizontalEffect];
    
    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"frame.origin.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = [NSNumber numberWithInt:-moveDistance];
    verticalEffect.maximumRelativeValue = [NSNumber numberWithInt:moveDistance];
    [contentView addMotionEffect:verticalEffect];
}



#pragma mark - User Interaction
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_tapToDismiss) {
        
        UITouch *touch = [touches anyObject];
        CGPoint tappedPoint = [touch locationInView: self];
        tappedPoint = [contentView convertPoint:tappedPoint fromView:self];
        
        if (!CGRectContainsPoint(contentView.bounds, tappedPoint)) {
            [self cancelButtonAction];
            [self dismiss:YES];
            return;
        }
    }
    
    [super touchesEnded:touches withEvent:event];
}

- (void)cancelButtonAction {
    
    if (_cancelButtonIndex >= 0 && _cancelButtonIndex < buttonArray.count &&
        [delegate respondsToSelector:@selector(actionSheet:didSelectItemAtIndex:)]) {
     
        [delegate actionSheet:self didSelectItemAtIndex:_cancelButtonIndex];
    }
}

- (void)setSwipeToDismiss:(BOOL)swipeToDismiss {
    
    _swipeToDismiss = swipeToDismiss;
    panGesture.enabled = _swipeToDismiss;
}

- (void)tapped:(UITapGestureRecognizer *)tap {
    
    if (!_tapToDismiss)
        return;
    
    CGPoint point = [tap locationInView:contentView];
    
    BOOL found = NO;
    
    if (!found && CGRectContainsPoint(contentView.bounds, point))
        found = YES;
    
    if (!found)
        [self dismiss:YES];
}

- (void)didTapButton:(UIButton *)sender
{
    NSInteger index = [buttonArray indexOfObject:sender];
    
    if (index == NSNotFound) {
        return;
    }
    
    if (delegate && [delegate respondsToSelector:@selector(actionSheet:didSelectItemAtIndex:)]) {
        [delegate actionSheet:self didSelectItemAtIndex:index];
    }
}

- (void)panned:(UIPanGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        
        self.contentView.transform = CGAffineTransformMakeTranslation(0, MAX(0, [sender translationInView:sender.view].y));
    } else if (sender.state != UIGestureRecognizerStateBegan) {
        
        if (self.contentView.transform.ty > self.contentView.frame.size.height / 3.0) {
            [self dismiss];
        } else {
            
            [UIView animateWithDuration:0.35
                                  delay:0.0
                 usingSpringWithDamping:1.0
                  initialSpringVelocity:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.contentView.transform = CGAffineTransformIdentity;
                             } completion:nil];
        }
        
    }
    
}

- (void)dismiss
{
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animated {

    [self dismiss:animated completion:nil];
    
}

- (void)dismiss:(BOOL)animated completion:(void (^)())completion {
    
    if (!animated)
    {
        [self dismissComplete];
        
        if (completion)
            completion();
    }
    else
    {
        
        parentView.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        [UIView animateWithDuration:[self.theme floatForKey:@"actionSheetDismissalTime"]
                         animations:^{
                             
                             self.contentView.transform = CGAffineTransformMakeTranslation(0,
                                                                                           self.contentView.frame.size.height);
                             self.backgroundColor = [UIColor clearColor];
                             
                         } completion:^(BOOL finished) {
                             [self dismissComplete];
                             
                             if (completion)
                                 completion();
                         }];
    }
    
}


- (void)dismissComplete
{
    [self removeFromSuperview];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheetDidDismiss:)]) {
        [delegate actionSheetDidDismiss:self];
    }
}



@end
