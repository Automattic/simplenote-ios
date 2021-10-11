//
//  SPTagTextView.m
//  Simplenote
//
//  Created by Tom Witkin on 7/24/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPTagEntryField.h"
#import "Simplenote-Swift.h"

CGFloat const TagEntryFieldPadding = 40;

@implementation SPTagEntryField

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.textColor = [UIColor simplenoteTagViewTextColor];
        self.placeholdTextColor = [UIColor simplenoteTagViewPlaceholderColor];
        self.textAlignment = NSTextAlignmentNatural;
        self.placeholder = NSLocalizedString(@"Tag…", @"Placeholder text in textfield when adding a new tag to a note");
        self.returnKeyType = UIReturnKeyNext;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;


        self.accessibilityLabel = NSLocalizedString(@"Add tag", @"Label on button to add a new tag to a note");
        self.accessibilityHint = NSLocalizedString(@"Add a tag to the current note", @"Accessibility hint for adding a tag to a note");

        [self sizeField];

        [self addTarget:self action:@selector(onTextChanged:) forControlEvents:UIControlEventEditingChanged];
    }

    return self;
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

    frame.size.width += 2 * TagEntryFieldPadding;
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

- (void)paste:(id)sender
{
    [self pasteTag];
}

@end
