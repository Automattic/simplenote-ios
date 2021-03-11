//
//  SPEditorTextView.m
//  Simplenote
//
//  Created by Tom Witkin on 8/16/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPEditorTextView.h"
#import "SPInteractiveTextStorage.h"
#import "NSMutableAttributedString+Styling.h"
#import "Simplenote-Swift.h"

NSString *const MarkdownUnchecked = @"- [ ]";
NSString *const MarkdownChecked = @"- [x]";
NSString *const TextAttachmentCharacterCode = @"\U0000fffc"; // Represents the glyph of an NSTextAttachment

static CGFloat const TextViewContanerInsetsTop = 8;
static CGFloat const TextViewContanerInsetsBottom = 88;

// TODO: Drop this the second SplitViewController is implemented
static CGFloat const TextViewRegularByRegularPadding = 64;
static CGFloat const TextViewDefaultPadding = 20;

// TODO: Drop this the second SplitViewController is implemented
static CGFloat const TextViewMaximumWidthPad = 640;
static CGFloat const TextViewMaximumWidthPhone = 0;

// One unicode character plus a space
NSInteger const ChecklistCursorAdjustment = 2;


@interface SPEditorTextView ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) SPEditorTapRecognizerDelegate *internalRecognizerDelegate;
@property (strong, nonatomic) NSArray *textCommands;
@property (nonatomic) UITextLayoutDirection verticalMoveDirection;
@property (nonatomic) CGRect verticalMoveStartCaretRect;
@property (nonatomic) CGRect verticalMoveLastCaretRect;
@property (nonatomic) BOOL isInserting;
@property (nonatomic) BOOL isDeletingBackward;

@end

@implementation SPEditorTextView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = YES;
        self.scrollEnabled = YES;
        self.verticalMoveStartCaretRect = CGRectZero;
        self.verticalMoveLastCaretRect = CGRectZero;

        [self setupTextContainerInsets];
        [self setupGestureRecognizers];
        [self startListeningToNotifications];

        // Why: Data Detectors simply don't work if `isEditable = YES`
        [self setEditable:NO];
    }

    return self;
}

- (void)setupTextContainerInsets
{
    UIEdgeInsets containerInsets = self.textContainerInset;
    containerInsets.top += TextViewContanerInsetsTop;
    containerInsets.bottom += TextViewContanerInsetsBottom;
    self.textContainerInset = containerInsets;
}

- (void)setupGestureRecognizers
{
    SPEditorTapRecognizerDelegate *recognizerDelegate = [SPEditorTapRecognizerDelegate new];
    recognizerDelegate.parentTextView = self;
    self.internalRecognizerDelegate = recognizerDelegate;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(onTextTapped:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = recognizerDelegate;
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)startListeningToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEndEditing:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
}

- (NSDictionary *)typingAttributes
{
    return self.text.length == 0 ? self.interactiveTextStorage.headlineStyle : self.interactiveTextStorage.defaultStyle;
}

// TODO: Drop this the second SplitViewController is implemented
- (CGFloat)horizontalPadding
{
    return [UIDevice isPad] && !self.isHorizontallyCompact ? TextViewRegularByRegularPadding : TextViewDefaultPadding;
}

// TODO: Drop this the second SplitViewController is implemented
- (CGFloat)maximumWidth
{
    return [UIDevice isPad] ? TextViewMaximumWidthPad : TextViewMaximumWidthPhone;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat padding = self.horizontalPadding;
    padding += self.safeAreaInsets.left;

    CGFloat maxWidth = self.maximumWidth;
    CGFloat width = self.bounds.size.width;
    
    if (width - 2 * padding > maxWidth && maxWidth > 0) {
        padding = (width - maxWidth) * 0.5;
    }

    self.textContainer.lineFragmentPadding = padding;
}

- (BOOL)becomeFirstResponder
{
    // Editable status is true by default but we fiddle with it during setup.
    
    self.editable = YES;
    return [super becomeFirstResponder];
}

- (void)insertText:(NSString *)text
{
    self.isInserting = YES;
    [super insertText:text];
    self.isInserting = NO;
}

- (void)deleteBackward
{
    self.isDeletingBackward = YES;
    [super deleteBackward];
    self.isDeletingBackward = NO;
}

- (BOOL)resignFirstResponder
{
    // TODO: Only invalidate when resigning.
    // This can be called multiple times while updating the responder chain.
    // Ideally, we'd only invalidate the layout when the call to super is successful.
    
    BOOL response = [super resignFirstResponder];
    [self setNeedsLayout];
    return response;
}

- (void)scrollToBottomWithAnimation:(BOOL)animated
{
    /// Notes:
    /// -   We consider `adjusted bottom inset` because that's how we inject the Tags Editor padding!
    /// -   And we don't consider `adjusted top insets` since that deals with navbar overlaps, and doesn't affect our calculations.

    CGFloat visibleHeight = self.bounds.size.height
                                - self.textContainerInset.top
                                - self.textContainerInset.bottom
                                - self.contentInset.bottom;
    if (self.contentSize.height <= visibleHeight) {
        return;
    }

    CGFloat yOffset = self.contentSize.height + self.adjustedContentInset.bottom - self.bounds.size.height;

    if (self.contentOffset.y == yOffset) {
        return;
    }

    CGPoint scrollOffset = CGPointMake(0, yOffset);
    [self setContentOffset:scrollOffset animated:animated];
}

- (void)scrollToTop
{
    CGFloat yOffset = self.bounds.origin.y - self.contentInset.top;
    CGPoint scrollOffset = CGPointMake(0, yOffset);
    [self setContentOffset:scrollOffset animated:NO];
}


#pragma mark - Notifications

- (void)didEndEditing:(NSNotification *)notification
{
    [self setEditable:NO];
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

#pragma mark - Checklists

- (void)processChecklists
{
    if (self.attributedText.length == 0) {
        return;
    }

    [self.textStorage processChecklistsWithColor:self.checklistsTintColor
                                      sizingFont:self.checklistsFont
                           allowsMultiplePerLine:NO];
}

- (void)insertOrRemoveChecklist
{
    NSRange lineRange = [self.text lineRangeForRange:self.selectedRange];
    NSUInteger cursorPosition = self.selectedRange.location;
    NSUInteger selectionLength = self.selectedRange.length;
    
    // Check if cursor is at a checkbox, if so we won't adjust cursor position
    BOOL cursorIsAtCheckbox = NO;
    if (self.text.length >= self.selectedRange.location + 1) {
        NSString *characterAtCursor = [self.text substringWithRange:NSMakeRange(self.selectedRange.location, 1)];
        cursorIsAtCheckbox = [characterAtCursor isEqualToString:TextAttachmentCharacterCode];
    }
    
    NSString *lineString = [self.text substringWithRange:lineRange];
    BOOL didInsertCheckbox = NO;
    NSString *resultString = @"";
    
    int addedCheckboxCount = 0;
    if ([lineString containsString:TextAttachmentCharacterCode] && [lineString length] >= ChecklistCursorAdjustment) {
        // Remove the checkboxes in the selection
        NSString *codeAndSpace = [TextAttachmentCharacterCode stringByAppendingString:@" "];
        resultString = [lineString stringByReplacingOccurrencesOfString:codeAndSpace withString:@""];
    } else {
        // Add checkboxes to the selection
        NSString *checkboxString = [MarkdownUnchecked stringByAppendingString:@" "];
        NSArray *stringLines = [lineString componentsSeparatedByString:@"\n"];
        for (int i=0; i < [stringLines count]; i++) {
            NSString *line = stringLines[i];
            // Skip the last line if it is empty
            if (i != 0 && i == [stringLines count] - 1 && [line length] == 0) {
                continue;
            }
            
            NSString *prefixedWhitespace = [self getLeadingWhiteSpaceForString:line];
            line = [line substringFromIndex:[prefixedWhitespace length]];
            resultString = [[resultString
                             stringByAppendingString:prefixedWhitespace]
                             stringByAppendingString:[checkboxString
                             stringByAppendingString:line]];
            // Skip adding newline to the last line
            if (i != [stringLines count] - 1) {
                resultString = [resultString stringByAppendingString:@"\n"];
            }
            addedCheckboxCount++;
        }

        didInsertCheckbox = YES;
    }
    
    NSTextStorage *storage = self.textStorage;
    [storage beginEditing];
    [storage replaceCharactersInRange:lineRange withString:resultString];
    [storage endEditing];
    
    // Update the cursor position
    NSUInteger cursorAdjustment = 0;
    if (!cursorIsAtCheckbox) {
        if (selectionLength > 0 && didInsertCheckbox) {
            // Places cursor at end of insertion when text was selected
            cursorAdjustment = selectionLength + (ChecklistCursorAdjustment * addedCheckboxCount);
        } else {
            cursorAdjustment = didInsertCheckbox ? ChecklistCursorAdjustment : -ChecklistCursorAdjustment;
        }
    }
    [self setSelectedRange:NSMakeRange(cursorPosition + cursorAdjustment, 0)];
    
    [self processChecklists];
    [self.delegate textViewDidChange:self];
    
    // Set the capitalization type to 'Words' temporarily so that we get a capital word next to the bullet.
    self.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [self reloadInputViews];
}

// Returns a NSString of any whitespace characters found at the start of a string
- (NSString *)getLeadingWhiteSpaceForString: (NSString *)string
{
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"^\\s*" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    
    return [string substringWithRange:match.range];
}

- (void)onTextTapped:(UITapGestureRecognizer *)recognizer
{
    NSUInteger characterIndex = [recognizer characterIndexInTextView:self];

    if (characterIndex < self.textStorage.length) {
        if ([self handlePressedAttachmentAtIndex:characterIndex] ||
            [self handlePressedLinkAtIndex:characterIndex]) {
            recognizer.cancelsTouchesInView = YES;
            return;
        }
    }

    CGPoint locationInView = [recognizer locationInView:self];
    [self handlePressedLocation:locationInView];
    recognizer.cancelsTouchesInView = NO;
}

- (void)handlePressedLocation:(CGPoint)point
{
    [self becomeFirstResponder];

    // Move the cursor to the tapped position
    UITextPosition *position = [self closestPositionToPoint:point];
    UITextRange *range = [self textRangeFromPosition:position toPosition:position];
    [self setSelectedTextRange:range];
}

- (BOOL)handlePressedAttachmentAtIndex:(NSUInteger)characterIndex
{
    NSRange attachmentRange;
    SPTextAttachment *attachment = [self.attributedText attribute:NSAttachmentAttributeName atIndex:characterIndex effectiveRange:&attachmentRange];
    if ([attachment isKindOfClass:[SPTextAttachment class]] == false) {
        return NO;
    }

    BOOL wasChecked = attachment.isChecked;
    attachment.isChecked = !wasChecked;

    // iOS 13 Bugfix:
    // Move the TextView Selection to the end of the TextAttachment's line
    // This prevents the UIMenuController from showing up after toggling multiple TextAttachments in a row.
    [self selectEndOfLineForRange:attachmentRange];

    // iOS 14 Bugfix:
    // Ensure the Attachment is onscreen. This prevents iOS 14 from bouncing back to the selected location
    if (@available(iOS 14.0, *)) {
        [self scrollRangeToVisible:self.selectedRange];
    }

    [self.delegate textViewDidChange:self];
    [self.layoutManager invalidateDisplayForCharacterRange:attachmentRange];

    return YES;
}

- (BOOL)handlePressedLinkAtIndex:(NSUInteger)characterIndex
{
    if (![self performsAggressiveLinkWorkaround]) {
        return NO;
    }

    NSURL *link = [self.attributedText attribute:NSLinkAttributeName atIndex:characterIndex effectiveRange:nil];
    if ([link isKindOfClass:[NSURL class]] == NO || [link containsHttpScheme] == NO) {
        return NO;
    }

    [self.editorTextDelegate textView:self receivedInteractionWithURL:link];

    return YES;
}

- (void)selectEndOfLineForRange:(NSRange)range
{
    NSRange lineRange = [self.text lineRangeForRange:range];
    if (lineRange.location == NSNotFound) {
        return;
    }

    NSInteger endOfLine = NSMaxRange(lineRange) - 1;
    if (endOfLine < 0 || endOfLine > self.textStorage.length) {
        return;
    }

    self.selectedRange = NSMakeRange(endOfLine, 0);
}

- (BOOL)performsAggressiveLinkWorkaround
{
    if (@available(iOS 13.2, *)) {
        return NO;
    }

    if (@available(iOS 13, *)) {
        return YES;
    }

    return NO;
}

- (id<SPEditorTextViewDelegate>)editorTextDelegate
{
    if ([self.delegate conformsToProtocol:@protocol(SPEditorTextViewDelegate)]) {
        return (id<SPEditorTextViewDelegate>)self.delegate;
    }

    return nil;
}

@end
