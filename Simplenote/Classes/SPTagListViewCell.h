#import <UIKit/UIKit.h>


@class SPTagListViewCell;

@protocol SPTagListViewCellDelegate <NSObject>

@required
- (void)tagListViewCellShouldDeleteTag:(SPTagListViewCell *)cell;
- (void)tagListViewCellShouldRenameTag:(SPTagListViewCell *)cell;
@end

@interface SPTagListViewCell : UITableViewCell {    
    BOOL hasHighlightedTextColor;
    BOOL performedInitialLayout;
}

@property (nonatomic, weak) id<SPTagListViewCellDelegate>   delegate;
@property (nonatomic, strong) UITextField                   *tagNameTextField;
@property (nonatomic, strong) UIColor                       *textColor;
@property (nonatomic, strong) UIColor                       *highlightedTextColor;
@property (nonatomic, strong) UIFont                        *textFont;

- (void)setIconImage:(UIImage *)image;
- (void)resetCellForReuse;
- (void)setTagNameText:(NSString *)text;
- (void)setTextFieldEditable:(BOOL)editable;

@end
