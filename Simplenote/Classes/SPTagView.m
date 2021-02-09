//
//  SPTagView.m
//  Simplenote
//
//  Created by Tom Witkin on 7/17/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTagView.h"
#import "SPTagStub.h"
#import <Simperium/Simperium.h>
#import "SPAppDelegate.h"
#import "Tag.h"
#import "NSString+Metadata.h"
#import "SPTagEntryField.h"
#import "SPTagPill.h"
#import "SPTagCompletionPill.h"
#import "Simplenote-Swift.h"



@interface SPTagView ()

@property (nonatomic, strong) SPTagPill *activeDeletionPill;
@property (nonatomic, strong) NSTimer *activeDeletionPillTimer;

@end

@implementation SPTagView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure
{
    /// Note:
    /// `scrollEnabled = NO` causes layout issues when `UITextField` becomes the first responder, in
    /// certain documents. We're simply always allowing scroll, and fixing a glitch!
    ///
    tagScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    tagScrollView.scrollsToTop = NO;
    tagScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tagScrollView.alwaysBounceHorizontal = YES;
    tagScrollView.showsHorizontalScrollIndicator = NO;
    tagScrollView.delegate = self;
    tagScrollView.scrollEnabled = YES;
    [self addSubview:tagScrollView];

    autoCompleteScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    autoCompleteScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    autoCompleteScrollView.alwaysBounceHorizontal = YES;
    autoCompleteScrollView.showsHorizontalScrollIndicator = NO;
    autoCompleteScrollView.delegate = self;
    autoCompleteScrollView.hidden = YES;
    [self addSubview:autoCompleteScrollView];

    addTagField = [SPTagEntryField tagEntryField];
    addTagField.delegate = self;
    addTagField.tagDelegate = self;
    [tagScrollView addSubview:addTagField];

    tagPills = [NSMutableArray array];

    [self ensureRightToLeftSupportIsInitialized];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    autoCompleteScrollView.backgroundColor = backgroundColor;
}

- (UIKeyboardAppearance)keyboardAppearance
{
    return addTagField.keyboardAppearance;
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance
{
    addTagField.keyboardAppearance = keyboardAppearance;
}

- (BOOL)isFirstResponder
{
    return addTagField.isFirstResponder;
}

- (void)layoutSubviews
{
    CGFloat xOrigin = 0.0;
    CGFloat spacing = TagPillSpacing.dx;
    
    // position tags
    for (UIView *view in tagPills) {
        view.frame = CGRectMake(xOrigin,
                             0.0,
                             view.frame.size.width,
                             self.bounds.size.height);
        
        xOrigin += view.frame.size.width;
        
    }

    // position button
    addTagField.frame = CGRectMake(xOrigin + spacing,
                                    0,
                                    addTagField.frame.size.width,
                                    self.bounds.size.height);
    
    xOrigin += addTagField.frame.size.width + 2 * spacing;

    tagScrollView.contentSize = CGSizeMake(xOrigin,
                                  tagScrollView.contentSize.height);
    
    CGRect bounds = self.bounds;
    bounds.origin.y = tagScrollView.frame.origin.y;
    tagScrollView.frame = bounds;
    
    xOrigin = 0.0;
    for (UIView *view in tagCompletionPills) {
        
        view.frame = CGRectMake(xOrigin,
                                0,
                                view.frame.size.width,
                                autoCompleteScrollView.bounds.size.height);
        
        xOrigin += view.frame.size.width;
    }
    
    autoCompleteScrollView.contentSize = CGSizeMake(xOrigin,
                                           autoCompleteScrollView.contentSize.height);
    
    bounds.origin.y -= bounds.size.height;
    autoCompleteScrollView.frame = bounds;
}

- (BOOL)setupWithTagNames:(NSArray *)tagNames {

    if (addTagField.isFirstResponder) {
        return NO;
    }
    
    [self clearAllTags];
    
    for (NSString *tag in tagNames) {
        
        if (![tag isValidEmailAddress])
            [self newTagPillWithString:tag];
    }
    
    [self setNeedsLayout];
    
    return YES;
}

- (void)clearAllTags {
    
    for (UIView *view in tagPills) {
        [view removeFromSuperview];
    }
    
    tagPills = [NSMutableArray array];
    [self setNeedsLayout];
}


- (void)removeTagAction:(SPTagPill *)pill {
    
    [tagPills removeObject:pill];
    [pill removeFromSuperview];
    
    if ([self.tagDelegate respondsToSelector:@selector(tagView:didRemoveTagName:)]) {
        [self.tagDelegate tagView:self didRemoveTagName:pill.tagStub.tag];
    }
    
    [self setNeedsLayout];
}

- (SPTagPill *)newTagPillWithString:(NSString *)string {
    SPTagPill *pill = [[SPTagPill alloc] initWithTagStub:[[SPTagStub alloc] initWithTag:string]
                                                  target:self
                                                  action:@selector(tagPillTapped:)
                                          deletionAction:@selector(removeTagAction:)];
    pill.transform = [self transformForScrollViewContent];
    [tagPills addObject:pill];
    [tagScrollView addSubview:pill];
    
    return pill;
}


#pragma mark auto-complete

- (void)updateAutoCompletionsForString:(NSString *)string {
    
    // remove all current subviews in autoCompleteScrollView
    for (UIView *v in tagCompletionPills) {
        [v removeFromSuperview];
    }
    
    tagCompletionPills = nil;
    
    // create new views for matching
    if (string.length > 0) {
        
        NSArray *matchingTags = [self matchingTagsForString:string];
        if (matchingTags.count > 0) {
            
            NSMutableArray *fields = [NSMutableArray arrayWithCapacity:matchingTags.count];
            
            for (SPTagStub *tagStub in matchingTags) {
                
                SPTagPill *matchButton = [[SPTagCompletionPill alloc] initWithTagStub:tagStub
                                                                               target:self
                                                                               action:@selector(tagCompletionPillTapped:)
                                                                       deletionAction:nil];

                matchButton.transform = [self transformForScrollViewContent];
                [autoCompleteScrollView addSubview:matchButton];
                [fields addObject:matchButton];
                
            }
         
            tagCompletionPills = [NSArray arrayWithArray:fields];
            
            autoCompleteScrollView.hidden = NO;
            [_tagDelegate tagView:self didChangeAutocompleteVisibility:YES];
            return;
        }
    }
    
    autoCompleteScrollView.hidden = YES;
    [_tagDelegate tagView:self didChangeAutocompleteVisibility:NO];
}

-(NSArray *)allTags {
    
    SPBucket *tagBucket = [[SPAppDelegate sharedDelegate].simperium bucketForName:@"Tag"];
    return [tagBucket allObjects];
}

-(NSArray *)tagStubsForTags:(NSArray *)tags {
    
    NSMutableArray *tagStubs = [NSMutableArray arrayWithCapacity:[tags count]];
    for (Tag *tag in tags) {
        SPTagStub *stub = [[SPTagStub alloc] initWithTag:tag.name];
        [tagStubs addObject:stub];
    }
    
    return tagStubs;
}

- (NSArray *)matchingTagsForString:(NSString *)input {
    
    if (input == nil)
        return nil;
    
    NSString *lowercaseInput = [input lowercaseString];
    NSMutableArray *temp = [NSMutableArray array];
    
    for (SPTagStub *t in [self tagStubsForTags:self.allTags]) {
        
        NSRange range = [[t.tag lowercaseString] rangeOfString:lowercaseInput];

        if (range.location == 0) {
            
            // check to make sure matching tag isn't already applied to note
            BOOL showTag = YES;
            for (SPTagPill *pill in tagPills) {
                if ([pill.tagStub.tag.lowercaseString isEqualToString:t.tag.lowercaseString]) {
                    showTag = NO;
                    break;
                }
            }
            
            if (showTag)
                [temp addObject:t];
        }
    }
    
    [temp sortUsingSelector:@selector(compare:)];
    return temp;
}

#pragma mark textField delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self hideActiveDeletionPill];
        
    [self updateAutoCompletionsForString:textField.text];
    [self setNeedsLayout];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.tagDelegate respondsToSelector:@selector(tagViewDidBeginEditing:)])
            [self.tagDelegate tagViewDidBeginEditing:self];
        
        [self scrollEntryFieldToVisible:YES];
    });
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [self validateInput:textField range:range replacement:string];
}

- (void)tagEntryFieldDidChange:(SPTagEntryField *)tagTextField {
    
    [self hideActiveDeletionPill];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollEntryFieldToVisible:YES];
    });
    
    if ([self.tagDelegate respondsToSelector:@selector(tagViewDidChange:)]) {
        [self.tagDelegate tagViewDidChange:self];
    }
    
    [self updateAutoCompletionsForString:tagTextField.text];

    [self setNeedsLayout];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // create a new tag
    [self processTextInFieldToTag];
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self hideActiveDeletionPill];
    
    [self processTextInFieldToTag];
}

- (void)processTextInFieldToTag {
    
    // there may be multiple tags
    NSString *name = addTagField.text;
    BOOL containsEmailAddress = [name isValidEmailAddress];
    

    if (name.length > 0 && [self.tagDelegate tagView:self shouldCreateTagName:name] && !containsEmailAddress) {
        
        NSString *cleanedName = [name stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
        [self newTagPillWithString:cleanedName];
        [self.tagDelegate tagView:self didCreateTagName:cleanedName];
        
    } else {
        
        if (containsEmailAddress) {

            NSString *title = [NSLocalizedString(@"Collaboration has moved", nil) capitalizedString];
            NSString *message = NSLocalizedString(@"Sharing notes is now accessed through the action menu from the toolbar.", nil);
            NSString *cancelTitle = NSLocalizedString(@"OK", nil);

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                     message:message
                                                                              preferredStyle:UIAlertControllerStyleAlert];

            [alertController addCancelActionWithTitle:cancelTitle handler:nil];
            [alertController presentFromRootViewController];
        }
    }
    
    addTagField.text = @"";
    
    [self updateAutoCompletionsForString:nil];
    
    [self setNeedsLayout];
}

- (void)scrollEntryFieldToVisible:(BOOL)animated
{
    if (_activeDeletionPill) {
        return;
    }

    if (tagScrollView.contentSize.width > tagScrollView.bounds.size.width &&
        addTagField.frame.origin.x + addTagField.frame.size.width - tagScrollView.contentOffset.x > tagScrollView.bounds.size.width) {

        CGPoint offset = CGPointMake(MIN(tagScrollView.contentSize.width - tagScrollView.bounds.size.width,
                                         addTagField.frame.origin.x + addTagField.frame.size.width - tagScrollView.bounds.size.width),
                                     0);
        
        [tagScrollView setContentOffset:offset animated:animated];
    }
}

- (void)showDeletionPill:(SPTagPill *)pill {
    
    if (![pill showingDeletionView]) {
        _activeDeletionPill = pill;
        [pill showDeletionView];
        
        
        // dismiss the pill after a certain duration
        
        _activeDeletionPillTimer = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                                    target:self
                                                                  selector:@selector(hideActiveDeletionPill)
                                                                  userInfo:nil
                                                                   repeats:NO];
        
    }
}

- (void)hideActiveDeletionPill {
    
    if (_activeDeletionPill) {
        [_activeDeletionPill hideDeletionView];
        _activeDeletionPill = nil;
        [_activeDeletionPillTimer invalidate];
        _activeDeletionPillTimer = nil;
    }
}

- (BOOL)endEditing:(BOOL)force {
    
    [self hideActiveDeletionPill];
    return [super endEditing:force];
}

#pragma mark gestures

- (void)tagCompletionPillTapped:(id)sender {
    
    if (tagScrollView.isDecelerating || tagScrollView.dragging) {
        return;
    }
    
    addTagField.text = [(SPTagPill *)sender tagStub].tag;
    [self processTextInFieldToTag];
}

- (void)tagPillTapped:(id)sender {
    
    if (tagScrollView.isDecelerating || tagScrollView.dragging) {
        return;
    }
    
    [self hideActiveDeletionPill];
    
    SPTagPill *pill = (SPTagPill *)sender;
    
    [self showDeletionPill:pill];
}

- (BOOL)gesture:(UIGestureRecognizer *)gesutre withinView:(UIView *)view {
    
    CGPoint location = [gesutre locationInView:view];
    
    return (location.x > 0 &&
            location.x < view.frame.size.width &&
            location.y > 0 &&
            location.y < view.frame.size.height);
}

#pragma mark - UIScrollViewDelegate methods

// allow touches outside view
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    for(UIView *subview in self.subviews)
    {
        UIView *view = [subview hitTest:[self convertPoint:point toView:subview] withEvent:event];
        if(view) return view;
    }
    return [super hitTest:point withEvent:event];
}


#pragma mark - RTL Support

- (void)ensureRightToLeftSupportIsInitialized
{
    if (self.userInterfaceLayoutDirection != UIUserInterfaceLayoutDirectionRightToLeft) {
        return;
    }

    /// Note:
    /// In order to support RTL, we need our tags to be anchored to the right hand side of the screen (our origin of coordinates).
    ///
    /// In our current approach, we'll vertically flip the container TagView, and flip again all of its subviews: [Tag Pills, Autocompletion and New Tag Editor]
    /// This will rendered a right-anchored Tags Editor, in just a few lines.
    ///
    self.transform = [self verticalFlipTransform];
    addTagField.transform = [self verticalFlipTransform];
    addTagField.textAlignment = NSTextAlignmentRight;
}

- (CGAffineTransform)verticalFlipTransform
{
    return CGAffineTransformScale(CGAffineTransformIdentity, -1, 1);
}

- (CGAffineTransform)transformForScrollViewContent
{
    if (self.userInterfaceLayoutDirection != UIUserInterfaceLayoutDirectionRightToLeft) {
        return CGAffineTransformIdentity;
    }

    return self.verticalFlipTransform;
}

@end
