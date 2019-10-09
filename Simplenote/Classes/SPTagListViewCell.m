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
        
        _textColor = [UIColor colorWithName:UIColorNameTextColor];
        _highlightedTextColor = [UIColor colorWithName:UIColorNameTintColor];
        
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
        
        _tagNameTextField = [[UITextField alloc] init];
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

        UIColor *textColor = self.highlighted || self.selected ? _highlightedTextColor : _textColor;
        if (![self.tagNameTextField.textColor isEqual:textColor]) {
            self.tagNameTextField.textColor = textColor;
        }
        
        self.imageView.tintColor = self.highlighted || self.selected ? _highlightedTextColor : _textColor;
        self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        [self resetCellForReuse];
    }
    return self;
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
    
    if (hasHighlightedTextColor != (self.highlighted || self.selected)) {
        [self setTagNameText:_tagNameTextField.text];
        self.imageView.tintColor = self.highlighted || self.selected ? _highlightedTextColor : _textColor;
        self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (void)setIconImage:(UIImage *)image {
    
    if (image.renderingMode == UIImageRenderingModeAlwaysTemplate)
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.imageView.tintColor = self.highlighted || self.selected ? _highlightedTextColor : _textColor;
    self.imageView.image = image;
}

- (void)setTagNameText:(NSString *)text {
    
    hasHighlightedTextColor = self.highlighted || self.selected;
    
    NSDictionary *textAttributes = @{
        NSFontAttributeName: self.textFont,
        NSForegroundColorAttributeName: hasHighlightedTextColor ? _highlightedTextColor : _textColor
    };
    
    NSAttributedString *titleAttributesString;
    
    if (text) {
        titleAttributesString = [[NSAttributedString alloc] initWithString:text attributes:textAttributes];
    }
    
    self.tagNameTextField.attributedText = titleAttributesString;
}

- (void)setTextFieldEditable:(BOOL)editable {
    
    _tagNameTextField.enabled = editable;
}

- (void)resetCellForReuse {

    [self setTextFieldEditable:NO];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];
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
