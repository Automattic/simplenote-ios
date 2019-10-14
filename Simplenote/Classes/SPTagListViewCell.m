#import "SPTagListViewCell.h"
#import "Simplenote-Swift.h"


@interface SPTagListViewCell ()
@property (nonatomic, strong) IBOutlet UIImageView *leftImageView;
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
        ((state & UITableViewCellStateDefaultMask) == UITableViewCellStateDefaultMask && self.tagNameTextField.isFirstResponder)) {

        [self.tagNameTextField endEditing:true];
    }
}

- (void)reset {
    self.accessoryType = UITableViewCellAccessoryNone;
    self.leftImage = nil;
    self.tagNameTextField.enabled = NO;
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
    self.leftImageView.tintColor = [UIColor colorWithName:UIColorNameSimplenoteMidBlue];
    self.tagNameTextField.textColor = [UIColor colorWithName:UIColorNameTextColor];
}

- (UIImage *)leftImage {
    return self.leftImageView.image;
}

- (void)setLeftImage:(UIImage *)leftImage {
    self.leftImageView.image = leftImage;
    self.leftImageView.hidden = leftImage == nil;
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
