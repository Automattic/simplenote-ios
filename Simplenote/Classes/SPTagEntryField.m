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

+ (SPTagEntryField *)tagEntryFieldWithdelegate:(id<SPTagEntryFieldDelegate>)tagDelegate {
    
    SPTagEntryField *newTagText = [[SPTagEntryField alloc] init];
    newTagText.backgroundColor = [UIColor clearColor];
    newTagText.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    newTagText.textColor = [newTagText.theme colorForKey:@"tagViewFontColor"];
    newTagText.placeholdTextColor = [newTagText.theme colorForKey:@"tagViewPlaceholderColor"];
    newTagText.tagDelegate = tagDelegate;
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

-(id)init {
    self = [super init];
    if (self) {
        [self addTarget:self action:@selector(onTextChanged:) forControlEvents:UIControlEventEditingChanged];
    }

    return self;
}


- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

- (id<SPTagEntryFieldDelegate>)tagDelegate {
    
    return tagDelegate;
}

- (void)setTagDelegate:(id<SPTagEntryFieldDelegate>)newDelegate {
    
    tagDelegate = newDelegate;
}

- (void)setText:(NSString *)text {
    
    [super setText:text];
    
    // size field appropriately
    [self sizeField];
    
    if ([tagDelegate respondsToSelector:@selector(tagEntryFieldDidChange:)]) {
        [tagDelegate tagEntryFieldDidChange:self];
    }
}

- (void)sizeField {
    
    [self sizeToFit];
    
    CGRect frame = self.frame;
    
    frame.size.width += 8 * [self.theme floatForKey:@"tagViewItemPadding"];
    frame.size.height = self.frame.size.height;
    
    self.frame = frame;
}

- (void)onTextChanged:(UITextField *)textField {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self->tagDelegate respondsToSelector:@selector(tagEntryFieldDidChange:)]) {
            [self->tagDelegate tagEntryFieldDidChange:self];
        }

        [self sizeField];
    });
}



@end
