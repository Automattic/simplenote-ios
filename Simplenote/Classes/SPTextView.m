//
//  SPTextView.m
//  Simplenote
//
//  Created by Tom Witkin on 7/19/13.
//  Created by Michael Johnston on 7/19/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTextView.h"
#import <CoreFoundation/CFStringTokenizer.h>
#import "VSThemeManager.h"
#import "NSString+Search.h"
#import "SPInteractiveTextStorage.h"
#import "Simplenote-Swift.h"

@implementation SPTextView

- (instancetype)init {
    
    SPInteractiveTextStorage *textStorage = [[SPInteractiveTextStorage alloc] init];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(0, CGFLOAT_MAX)];
    container.widthTracksTextView = YES;
    container.heightTracksTextView = YES;
    [layoutManager addTextContainer:container];
    [textStorage addLayoutManager:layoutManager];
    
    self = [super initWithFrame:CGRectZero textContainer:container];
    if (self) {
        self.interactiveTextStorage = textStorage;
        
    /*
        Issue #188:
        ===========
     
        On iOS 8, the text (was) getting clipped onscreen. Reason: the TextContainer was being shrunk down, and never re-expanded.
        This was not happening on iOS 7, because [UITextView setScrollEnabled] method was disabling the
        textContainer.heightTracksTextView property (and thus, the NSTextContainer instance was maintaining the CGFLOAT_MAX height.
     
        As a workaround, we're disabling heightTracksTextView here, emulating iOS 7 behavior.
     
        NOTE: Disabling heightTracksTextView before the init has a side effect. caretRectForPosition will not calculate the right
        caret position.
     */
        self.textContainer.heightTracksTextView = NO;
    }
    return self;
}

#pragma mark - Words

- (void)highlightSubstringsMatching:(NSString *)keywords color:(UIColor *)color {

    [self.textStorage applyColor:color toSubstringMatchingKeywords:keywords];
}

- (void)highlightRange:(NSRange)range animated:(BOOL)animated withBlock:(void (^)(CGRect))block {
    
    [self clearHighlights:animated];
    
    highlightViews = [NSMutableArray arrayWithCapacity:range.length];
    
    [self.layoutManager enumerateLineFragmentsForGlyphRange:range
                                                 usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer *textContainer, NSRange glyphRange, BOOL *stop) {
                                                     
                                                     NSInteger location = MAX(glyphRange.location, range.location);
                                                     NSInteger length = MIN(glyphRange.length, range.length - (location - range.location));
                                                     
                                                     NSRange highlightRange = NSMakeRange(location, length);
                                                     
                                                     CGRect highlightRect = [self.layoutManager boundingRectForGlyphRange:highlightRange
                                                                                                          inTextContainer:textContainer];
                                                     
                                                     if (block)
                                                         block(highlightRect);
                                                     
                                                     UIView *highlightView = [self createHighlightViewForAttributedString:[self.textStorage attributedSubstringFromRange:highlightRange]
                                                                                                                    frame:highlightRect];
                                                     
                                                     
                                                     [self addSubview:highlightView];
                                                     [self->highlightViews addObject:highlightView];
                                                     
                                                     if (animated) {
                                                         
                                                         [UIView animateWithDuration:0.1
                                                                          animations:^{
                                                                              
                                                                              highlightView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                                                                              
                                                                          } completion:^(BOOL finished) {
                                                                              
                                                                              [UIView animateWithDuration:0.1
                                                                                                    delay:0.0
                                                                                   usingSpringWithDamping:0.6
                                                                                    initialSpringVelocity:10.0
                                                                                                  options:UIViewAnimationOptionCurveEaseOut
                                                                                               animations:^{
                                                                                                   highlightView.transform = CGAffineTransformIdentity;
                                                                                               } completion:nil];
                                                                              
                                                                          }];
                                                         
                                                     }
                                                     
                                                 }];
    
 
    
}

- (UIView *)createHighlightViewForAttributedString:(NSAttributedString *)attributedString frame:(CGRect)frame {
    
    frame.origin.y += 8;
    
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    CGFloat horizontalPadding = [theme floatForKey:@"searchHighlightHorizontalPadding"];
    CGFloat verticalPadding = [theme floatForKey:@"searchHighlightVerticalPadding"];
    
    frame.size.width += 2 * horizontalPadding;
    frame.origin.x -= horizontalPadding;
    frame.size.height += 2 * verticalPadding;
    frame.origin.y -= verticalPadding;
    
    UILabel *highlightLabel = [[UILabel alloc] initWithFrame:frame];
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor simplenoteSearchHighlightTextColor]
                                    range:NSMakeRange(0, mutableAttributedString.length)];

    highlightLabel.attributedText = mutableAttributedString;
    
    highlightLabel.textAlignment = NSTextAlignmentCenter;
    highlightLabel.backgroundColor = self.window.tintColor;
    highlightLabel.layer.cornerRadius = [theme floatForKey:@"searhHighlightCornerRadius"];
    highlightLabel.clipsToBounds = YES;
    highlightLabel.layer.shouldRasterize = YES;
    highlightLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    return highlightLabel;
}

- (void)clearHighlights:(BOOL)animated {
    
    
    if (animated) {
        
        
        for (UIView *highlightView in highlightViews) {
            UIView *highlightSnapshot = [highlightView snapshotViewAfterScreenUpdates:NO];
            highlightSnapshot.frame = highlightView.frame;
            [self addSubview:highlightSnapshot];
            
            [UIView animateWithDuration:0.1
                             animations:^{
                                 highlightSnapshot.alpha = 0.0;
                                 highlightSnapshot.transform = CGAffineTransformMakeScale(0.0, 0.0);
                             } completion:^(BOOL finished) {
                                 [highlightSnapshot removeFromSuperview];
                             }];
        }
    
    }
    for (UIView *highlightView in highlightViews) {
        [highlightView removeFromSuperview];

    }
    
    highlightViews = nil;
    
    
}

- (void)clearHighlights {
    
    [self clearHighlights:NO];
    
}

#pragma mark - 

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
    // This is a work around for an issue where the text view scrolls to its bottom
    // when a user selects all text. If the selected range matches the range of the
    // string, this method was likely called as a result of choosing the "Select All" method
    // of a UIMenuItem.  In these cases we just return to avoid scrolling the view.
    // For more info, see: https://github.com/Automattic/simplenote-ios/issues/263
    NSRange range = [self.text rangeOfString:self.text];
    NSRange selectedRange = self.selectedRange;
    if (range.location == selectedRange.location &&
        range.length == selectedRange.length) {
        return;
    }
    [super scrollRectToVisible:rect animated:animated];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    if (!animated) {
        [self setContentOffset:contentOffset];
        return;
    }

    /// Secret Technique™
    /// In order to _extremely_ match "Scroll to Selected Range" with any Keyboard animation, we'll introduce a custom animation.
    /// This yields a smooth experience, whenever the keyboard is revealed (and the TextView decides to scroll along)
    const UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews;
    const NSTimeInterval duration = 0.25;

    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:duration delay:UIKitConstants.animationDelayZero options:options animations:^{
        [self setContentOffset:contentOffset];
    } completion:nil];
}

@end
