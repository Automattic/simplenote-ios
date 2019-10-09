#import <UIKit/UIKit.h>


@class SPTagListViewCell;

@protocol SPTagListViewCellDelegate <NSObject>

@required
- (void)tagListViewCellShouldDeleteTag:(SPTagListViewCell *)cell;
- (void)tagListViewCellShouldRenameTag:(SPTagListViewCell *)cell;
@end

@interface SPTagListViewCell : UITableViewCell {    
    BOOL performedInitialLayout;
}

@property (nonatomic, weak) id<SPTagListViewCellDelegate>   delegate;
@property (nonatomic, strong) UITextField                   *tagNameTextField;
@property (nonatomic, strong) UIColor                       *textColor;
@property (nonatomic, strong) UIFont                        *textFont;
@property (nonatomic, assign) BOOL                          isTextFieldEditable;
@property (nonatomic, strong) NSString                      *tagNameText;

- (void)applyStyle;

@end
