//
//  SPTagTextView.m
//  Simplenote
//
//  Created by Tom Witkin on 7/24/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTagEntryField.h"
#import "Simplenote-Swift.h"
#import "VSThemeManager.h"

@implementation SPTagEntryField

+ (SPTagEntryField *)tagEntryField
{
    SPTagEntryField *newTagText = [SPTagEntryField new];
    newTagText.backgroundColor = [UIColor clearColor];
    newTagText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    newTagText.textColor = [UIColor simplenoteTagViewTextColor];
    newTagText.placeholdTextColor = [UIColor simplenoteTagViewPlaceholderColor];
    newTagText.textAlignment = NSTextAlignmentLeft;
    newTagText.placeholder = NSLocalizedString(@"Add a tag...", nil);
    newTagText.returnKeyType = UIReturnKeyNext;
    newTagText.autocorrectionType = UITextAutocorrectionTypeNo;
    newTagText.autocapitalizationType = UITextAutocapitalizationTypeNone;

    [newTagText setPlaceholder:NSLocalizedString(@"Add a tag...", @"Placeholder test in textfield when adding a new tag to a note")];
    
    newTagText.accessibilityLabel = NSLocalizedString(@"Add tag", @"Label on button to add a new tag to a note");
    newTagText.accessibilityHint = NSLocalizedString(@"tag-add-accessibility-hint", @"Accessibility hint for adding a tag to a note");
    
    [newTagText sizeField];

    return newTagText;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addTarget:self action:@selector(onTextChanged:) forControlEvents:UIControlEventEditingChanged];
    }

    return self;
}

- (VSTheme *)theme
{    
    return [[VSThemeManager sharedManager] theme];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    // size field appropriately
    [self sizeField];
    
    if ([self.tagDelegate respondsToSelector:@selector(tagEntryFieldDidChange:)]) {
        [self.tagDelegate tagEntryFieldDidChange:self];
    }
}

- (void)sizeField
{
    [self sizeToFit];
    
    CGRect frame = self.frame;
    
    frame.size.width += 8 * [self.theme floatForKey:@"tagViewItemPadding"];
    frame.size.height = self.frame.size.height;
    
    self.frame = frame;
}

- (void)onTextChanged:(UITextField *)textField
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.tagDelegate respondsToSelector:@selector(tagEntryFieldDidChange:)]) {
            [self.tagDelegate tagEntryFieldDidChange:self];
        }

        [self sizeField];
    });
}

/// Stop this madness, in the name of your king!
///
/// As you may know, the TagsEditor is contained within a UITextView instance. Meaning that resigning firstResponder status
/// causes the nextResponder to *actually* become the firstResponder.
///
/// In this simple, yet powerful workaround, we're skipping the "Enclosing Text View" from the receiver's responder chain.
///
/// Why:
///     - Dismissing the Tags Editor causes, otherwise, multiple keyboard events
///     - And as you may have guessed, that yields bad layout issues
///
- (UIResponder *)nextResponder
{
    return self.enclosingTextView.superview;
}

@end
