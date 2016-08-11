//
//  SPEditorTextView.m
//  Simplenote
//
//  Created by Tom Witkin on 8/16/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPEditorTextView.h"
#import "SPTagView.h"
#import "VSThemeManager.h"
#import "SPInteractiveTextStorage.h"
#import "NSString+Attributed.h"
#import "VSTheme+Extensions.h"

@interface SPEditorTextView ()

@property (strong, nonatomic) NSArray *textCommands;
@property (nonatomic) UITextLayoutDirection verticalMoveDirection;
@property (nonatomic) CGRect verticalMoveStartCaretRect;
@property (nonatomic) CGRect verticalMoveLastCaretRect;

@end

@implementation SPEditorTextView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        VSTheme *theme = [[VSThemeManager sharedManager] theme];
        
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = YES;
        self.scrollEnabled = YES;
        self.verticalMoveStartCaretRect = CGRectZero;
        self.verticalMoveLastCaretRect = CGRectZero;
        
        // add tag view
        
        CGFloat tagViewHeight = [theme floatForKey:@"tagViewHeight"];
        _tagView = [[SPTagView alloc] initWithFrame:CGRectMake(0, 0, 0, tagViewHeight)];
        _tagView.isAccessibilityElement = NO;
        
        [self addSubview:_tagView];
        
        UIEdgeInsets contentInset = self.contentInset;
        contentInset.bottom += 2 * tagViewHeight;
        contentInset.top += [theme floatForKey:@"noteTopPadding"];
        self.contentInset = contentInset;
        
        [self addObserver:self
               forKeyPath:@"contentSize"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        [self addObserver:self
               forKeyPath:@"contentOffset"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEndEditing:)
                                                     name:UITextViewTextDidEndEditingNotification
                                                   object:nil];
        
        [self setEditing:NO];
    }
    return self;
}

- (NSDictionary *)typingAttributes {
    
    return [self.interactiveTextStorage.tokens objectForKey:SPDefaultTokenName];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self && ([keyPath isEqualToString:@"contentOffset"] || [keyPath isEqualToString:@"contentSize"]))
        [self positionTagView];
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    // Set content insets on side
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    
    CGFloat padding = [theme floatForKey:@"noteSidePadding" contextView:self];
    CGFloat maxWidth = [theme floatForKey:@"noteMaxWidth"];
    CGFloat width = self.bounds.size.width;
    
    if (width - 2 * padding > maxWidth && maxWidth > 0)
        padding = (width - maxWidth) / 2.0;
    
    self.textContainer.lineFragmentPadding = padding;
    
    // position tag view at bottom
    [self positionTagView];
}

- (void)positionTagView {
    
    CGFloat height = _tagView.frame.size.height;
    CGFloat yOrigin = self.contentSize.height - height + self.contentInset.top;
    yOrigin = MAX(yOrigin, self.contentOffset.y + self.bounds.size.height - height);
    
    CGRect footerViewFrame = CGRectMake(0, yOrigin, self.bounds.size.width, height);
    _tagView.frame = footerViewFrame;
}

- (void)setTagView:(SPTagView *)tagView {
    
    if (_tagView) {
        [_tagView removeFromSuperview];
    }
    
    [self addSubview:tagView];
    _tagView = tagView;
    [self setNeedsLayout];
}

- (void)setEditing:(BOOL)editing {
    
    _editing = editing;
    self.editable = editing;
    
    // HACK:
    // God, forgive me. After enabling edit mode, "former" linkified substrings are rendered with a black color.
    // This forces UITextView to render those substrings with the same color as the rest of the TextView.
    self.textColor = self.textColor;
}

- (BOOL)becomeFirstResponder {
 
    touchBegan = YES;
    [self setEditing:YES];
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
        
    BOOL response = [super resignFirstResponder];
    [self setNeedsLayout];
    return response;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    touchBegan = YES;
    UITouch *touch = [touches anyObject];
	tappedPoint = [touch locationInView: self];
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
 
    if (touchBegan) {
        [self setEditing:YES];
        [self performSelector:@selector(postEdit) withObject:nil afterDelay:0.05];
        touchBegan = NO;
    }
    [super touchesEnded:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    touchBegan = NO;
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    touchBegan = NO;
    [super touchesMoved:touches withEvent:event];
}


-(void)postEdit {
    
//  Note: This is causing lags in large notes. Plus, not needed anymore in iOS 7.1.
//
//    // The text is reset in order to remove the coloring from the automatic
//    // data detectors. Phone numbers and URLs remain blue without this fix,
//    // while other data detectors are properly turned black.
//    self.attributedText = [self.text attributedString];
//
    
	[self becomeFirstResponder];
    
    NSInteger tappedIndex = [self.layoutManager characterIndexForPoint:tappedPoint
                                                       inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    
    if (tappedIndex >= self.text.length - 2)
        tappedIndex ++;

	self.selectedRange = NSMakeRange(tappedIndex, 0);
}

- (void)scrollToBottom {
    
    if (self.contentSize.height > self.bounds.size.height - self.contentInset.top - self.contentInset.bottom) {
        
        CGPoint scrollOffset = CGPointMake(0,
                                           self.contentSize.height + self.contentInset.bottom - self.bounds.size.height);
        [self setContentOffset:scrollOffset animated:NO];
    }
}

#pragma mark Notifications

- (void)didEndEditing:(NSNotification *)notification {
    
    [self setEditing:NO];
}

// Fixes are modified versions of https://gist.github.com/agiletortoise/a24ccbf2d33aafb2abc1

#pragma mark fixes for UITextView bugs in iOS 7

- (UITextPosition *)closestPositionToPoint:(CGPoint)point {
    
    point.y -= self.textContainerInset.top;
    point.x -= self.textContainerInset.left;
    
    NSUInteger glyphIndex = [self.layoutManager glyphIndexForPoint:point inTextContainer:self.textContainer];
    NSUInteger characterIndex = [self.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    
    if (characterIndex >= self.text.length - 1 && ![self.text hasSuffix:@"\n"])
        characterIndex ++;
    
    UITextPosition *pos = [self positionFromPosition:self.beginningOfDocument offset:characterIndex];
    
    return pos;
}

- (void)scrollRangeToVisible:(NSRange)range
{
    [super scrollRangeToVisible:range];
    
    if (self.layoutManager.extraLineFragmentTextContainer != nil && self.selectedRange.location == range.location)
    {
        CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start];
        [self scrollRectToVisible:caretRect animated:YES];
    }
}

- (NSUInteger)characterIndexForPoint:(CGPoint)point
{
    if (self.text.length == 0) {
        return 0;
    }
    
    CGRect r1;
    if ([[self.text substringFromIndex:self.text.length-1] isEqualToString:@"\n"]) {
        r1 = [super caretRectForPosition:[super positionFromPosition:self.endOfDocument offset:-1]];
        CGRect sr = [super caretRectForPosition:[super positionFromPosition:self.beginningOfDocument offset:0]];
        r1.origin.x = sr.origin.x;
        r1.origin.y += self.font.lineHeight;
    } else {
        r1 = [super caretRectForPosition:[super positionFromPosition:self.endOfDocument offset:0]];
    }
    
    if ((point.x > r1.origin.x && point.y >= r1.origin.y) || point.y >= r1.origin.y+r1.size.height) {
        return [super offsetFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    }
    
    CGFloat fraction;
    NSUInteger index = [self.textStorage.layoutManagers[0] characterIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:&fraction];
    
    return index;
}

- (CGRect)firstRectForRange:(UITextRange *)range
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        CGRect r1= [self caretRectForPosition:[self positionWithinRange:range farthestInDirection:UITextLayoutDirectionRight]];
        CGRect r2= [self caretRectForPosition:[self positionWithinRange:range farthestInDirection:UITextLayoutDirectionLeft]];
        return CGRectUnion(r1,r2);
    }
    return [super firstRectForRange:range];
}

// From https://gist.github.com/rcabaco/6765778
#pragma mark Keyboard Commands
    
- (NSArray *)keyCommands
{
    if (!self.textCommands) {
        UIKeyCommand *upCommand = [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:0 action:@selector(moveUp:)];
        UIKeyCommand *downCommand = [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:0 action:@selector(moveDown:)];
        self.textCommands = @[upCommand, downCommand];
    }
    return self.textCommands;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(moveUp:) || action == @selector(moveDown:)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

#pragma mark -

- (void)moveUp:(id)sender
{
    UITextPosition *p0 = self.selectedTextRange.start;
    if ([self isNewVerticalMovementForPosition:p0 inDirection:UITextLayoutDirectionUp]) {
        self.verticalMoveDirection = UITextLayoutDirectionUp;
        self.verticalMoveStartCaretRect = [self caretRectForPosition:p0];
    }
    
    if (p0) {
        UITextPosition *p1 = [self closestPositionToPosition:p0 inDirection:UITextLayoutDirectionUp];
        if (p1) {
            self.verticalMoveLastCaretRect = [self caretRectForPosition:p1];
            UITextRange *r = [self textRangeFromPosition:p1 toPosition:p1];
            self.selectedTextRange = r;
        }
    }
}

- (void)moveDown:(id)sender
{
    UITextPosition *p0 = self.selectedTextRange.end;
    if ([self isNewVerticalMovementForPosition:p0 inDirection:UITextLayoutDirectionDown]) {
        self.verticalMoveDirection = UITextLayoutDirectionDown;
        self.verticalMoveStartCaretRect = [self caretRectForPosition:p0];
    }
    
    if (p0) {
        UITextPosition *p1 = [self closestPositionToPosition:p0 inDirection:UITextLayoutDirectionDown];
        if (p1) {
            self.verticalMoveLastCaretRect = [self caretRectForPosition:p1];
            UITextRange* r = [self textRangeFromPosition:p1 toPosition:p1];
            self.selectedTextRange = r;
        }
    }
}

- (UITextPosition *)closestPositionToPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction
{
    // Currently only up and down are implemented.
    NSParameterAssert(direction == UITextLayoutDirectionUp || direction == UITextLayoutDirectionDown);
    
    // Translate the vertical direction to a horizontal direction.
    UITextLayoutDirection lookupDirection = (direction == UITextLayoutDirectionUp) ? UITextLayoutDirectionLeft : UITextLayoutDirectionRight;
    
    // Walk one character at a time in `lookupDirection` until the next line is reached.
    UITextPosition *checkPosition = position;
    UITextPosition *closestPosition = position;
    CGRect startingCaretRect = [self caretRectForPosition:position];
    CGRect nextLineCaretRect;
    BOOL isInNextLine = NO;
    while (YES) {
        UITextPosition *nextPosition = [self positionFromPosition:checkPosition inDirection:lookupDirection offset:1];
        if (!nextPosition || [self comparePosition:checkPosition toPosition:nextPosition] == NSOrderedSame) {
            // End of line.
            break;
        }
        
        checkPosition = nextPosition;
        CGRect checkRect = [self caretRectForPosition:checkPosition];
        if (CGRectGetMidY(startingCaretRect) != CGRectGetMidY(checkRect)) {
            // While on the next line stop just above/below the starting position.
            if (lookupDirection == UITextLayoutDirectionLeft && CGRectGetMidX(checkRect) <= CGRectGetMidX(self.verticalMoveStartCaretRect)) {
                closestPosition = checkPosition;
                break;
            }
            if (lookupDirection == UITextLayoutDirectionRight && CGRectGetMidX(checkRect) >= CGRectGetMidX(self.verticalMoveStartCaretRect)) {
                closestPosition = checkPosition;
                break;
            }
            // But don't skip lines.
            if (isInNextLine && CGRectGetMidY(checkRect) != CGRectGetMidY(nextLineCaretRect)) {
                break;
            }
            
            isInNextLine = YES;
            nextLineCaretRect = checkRect;
            closestPosition = checkPosition;
        }
    }
    return closestPosition;
}

- (BOOL)isNewVerticalMovementForPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction
{
    CGRect caretRect = [self caretRectForPosition:position];
    BOOL noPreviousStartPosition = CGRectEqualToRect(self.verticalMoveStartCaretRect, CGRectZero);
    BOOL caretMovedSinceLastPosition = !CGRectEqualToRect(caretRect, self.verticalMoveLastCaretRect);
    BOOL directionChanged = self.verticalMoveDirection != direction;
    
    BOOL newMovement = noPreviousStartPosition || caretMovedSinceLastPosition || directionChanged;
    return newMovement;
}

@end