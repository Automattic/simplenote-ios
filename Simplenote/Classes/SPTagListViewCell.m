#import "SPTagListViewCell.h"
#import "Simplenote-Swift.h"


@interface SPTagListViewCell ()
@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;
@end


@implementation SPTagListViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self refreshStyle];
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
    self.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];
}

- (void)refreshSelectionStyle {
    UIView *selectedView = [UIView new];
    selectedView.backgroundColor = [UIColor colorWithName:UIColorNameLightBlueColor];
    self.selectedBackgroundView = selectedView;
}

- (void)refreshComponentsStyle {
    self.iconImageView.tintColor = [UIColor colorWithName:UIColorNameSimplenoteMidBlue];
    self.textField.textColor = [UIColor colorWithName:UIColorNameTextColor];
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
