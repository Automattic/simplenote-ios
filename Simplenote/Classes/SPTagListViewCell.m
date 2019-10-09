#import "SPTagListViewCell.h"
#import "Simplenote-Swift.h"


@implementation SPTagListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupTextField];
    [self refreshStyle];
}

- (void)prepareForReuse {
    [super prepareForReuse];

    [self refreshStyle];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.isTextFieldEditable = NO;
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    
    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask ||
        ((state & UITableViewCellStateDefaultMask) == UITableViewCellStateDefaultMask && self.tagNameTextField.isFirstResponder)) {

        [self.tagNameTextField endEditing:true];
    }
}

- (void)setupTextField {
    self.tagNameTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.tagNameTextField.enabled = NO;
}

- (void)refreshStyle {
    self.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];
    self.leftImageView.tintColor = [UIColor colorWithName:UIColorNameSimplenoteMidBlue];
    self.tagNameTextField.textColor = [UIColor colorWithName:UIColorNameTextColor];
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
