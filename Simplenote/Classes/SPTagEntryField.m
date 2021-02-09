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
