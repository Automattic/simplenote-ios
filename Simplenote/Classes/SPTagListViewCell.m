#import "SPTagListViewCell.h"
#import "VSThemeManager.h"
#import "SPBorderedView.h"
#import "Simplenote-Swift.h"


@implementation SPTagListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;

        SPBorderedView *selectedBackgroundView = [[SPBorderedView alloc] initWithFrame:self.bounds];
        selectedBackgroundView.borderInset = [self.theme edgeInsetsForKey:@"tagListHighlightInset"];
        selectedBackgroundView.fillColor = [UIColor colorWithName:UIColorNameLightBlueColor];
        selectedBackgroundView.showLeftBorder = NO;
        selectedBackgroundView.showRightBorder = NO;
        selectedBackgroundView.showBottomBorder = NO;
        selectedBackgroundView.showTopBorder = NO;
        selectedBackgroundView.borderInset = UIEdgeInsetsMake(2, 5, 2, 5);
        selectedBackgroundView.cornerRadius = 4.0;
        self.selectedBackgroundView = selectedBackgroundView;
        
        _tagNameTextField = [UITextField new];
        _textFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        _tagNameTextField.font = _textFont;
        _tagNameTextField.textColor = _textColor;
        _tagNameTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tagNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _tagNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _tagNameTextField.keyboardType = UIKeyboardTypeAlphabet;
        _tagNameTextField.returnKeyType = UIReturnKeyDone;
        _tagNameTextField.isAccessibilityElement = NO;
        [self.contentView addSubview:_tagNameTextField];

        [self prepareForReuse];
    }

    return self;
}

- (void)applyStyle {
    self.imageView.tintColor = [UIColor colorWithName:UIColorNameSimplenoteMidBlue];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    
    if (state & UITableViewCellStateShowingDeleteConfirmationMask) {
        [self.tagNameTextField endEditing:true];
    }
}

- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

- (void)layoutSubviews {

    [super layoutSubviews];

    if (!performedInitialLayout) {
        
        CGFloat imageViewSide = [self.theme floatForKey:@"tagListImageViewSide"];
        CGFloat leftPadding = [self.theme floatForKey:@"tagListLeftPadding"];
        self.imageView.frame = CGRectMake(leftPadding,
                                          (self.bounds.size.height - imageViewSide) / 2.0,
                                          imageViewSide,
                                          imageViewSide);
        self.imageView.contentMode = UIViewContentModeCenter;
        
        CGFloat itemPadding = [self.theme floatForKey:@"tagListItemPadding"];
        
        CGFloat xOrigin = self.imageView.frame.origin.x + self.imageView.frame.size.width + itemPadding;
        xOrigin = self.imageView.image ? xOrigin : leftPadding;
        _tagNameTextField.frame = CGRectMake(xOrigin,
                                             0 + [self.theme floatForKey:@"tagListFontTopPadding"],
                                             self.bounds.size.width - xOrigin - leftPadding,
                                             self.bounds.size.height);
        performedInitialLayout = YES;
    }
}

- (void)setTagNameText:(NSString *)text {
    self.tagNameTextField.text = text;
}

- (NSString *)tagNameText {
    return self.tagNameTextField.text;
}

- (void)setIsTextFieldEditable:(BOOL)editable {
    self.tagNameTextField.enabled = editable;
}

- (BOOL)isTextFieldEditable {
    return self.tagNameTextField.enabled;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.accessoryType = UITableViewCellAccessoryNone;
    self.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];
    self.isTextFieldEditable = NO;
    self.tagNameTextField.textColor = [UIColor colorWithName:UIColorNameTextColor];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(rename:) || action == @selector(delete:)) && !_tagNameTextField.editing;
}

- (void)delete:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tagListViewCellShouldDeleteTag:)]) {
        [self.delegate tagListViewCellShouldDeleteTag:self];
    }
}

- (void)rename:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tagListViewCellShouldRenameTag:)]) {
        [self.delegate tagListViewCellShouldRenameTag:self];
    }
}

@end
