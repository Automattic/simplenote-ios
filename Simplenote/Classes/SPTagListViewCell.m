#import "SPTagListViewCell.h"
#import "Simplenote-Swift.h"


@interface SPTagListViewCell ()
@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;
@end


@implementation SPTagListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self refreshStyle];
    // Don't use textField as an accessibility element.
    // Instead use textField value as a cell accessibility label.
    self.textField.isAccessibilityElement = NO;
}

- (NSString *)accessibilityLabel {
    return self.textField.text;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self refreshStyle];
    [self reset];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];

    if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask ||
        ((state & UITableViewCellStateDefaultMask) == UITableViewCellStateDefaultMask && self.textField.isFirstResponder)) {

        [self.textField endEditing:true];
    }
}

- (void)reset {
    self.accessoryType = UITableViewCellAccessoryNone;
    self.iconImage = nil;
    self.textField.enabled = NO;
}

- (void)refreshStyle {
    [self refreshCellStyle];
    [self refreshSelectionStyle];
    [self refreshComponentsStyle];
}

- (void)refreshCellStyle {
    self.backgroundColor = [UIColor simplenoteBackgroundColor];
}

- (void)refreshSelectionStyle {
    UIView *selectedView = [UIView new];
    selectedView.backgroundColor = [UIColor simplenoteLightBlueColor];
    self.selectedBackgroundView = selectedView;
}

- (void)refreshComponentsStyle {
    self.iconImageView.tintColor = [UIColor simplenoteTintColor];
    self.textField.textColor = [UIColor simplenoteTextColor];
}

- (UIImage *)iconImage {
    return self.iconImageView.image;
}

- (void)setIconImage:(UIImage *)iconImage {
    self.iconImageView.image = iconImage;
    self.iconImageView.hidden = iconImage == nil;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(rename:) || action == @selector(delete:)) && !self.textField.editing;
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
