#import <UIKit/UIKit.h>


@class SPTagListViewCell;

@protocol SPTagListViewCellDelegate <NSObject>

@required
- (void)tagListViewCellShouldDeleteTag:(SPTagListViewCell *)cell;
- (void)tagListViewCellShouldRenameTag:(SPTagListViewCell *)cell;
@end


@interface SPTagListViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField          *textField;
@property (nonatomic, strong) UIImage                       *iconImage;
@property (nonatomic, weak) id<SPTagListViewCellDelegate>   delegate;

@end
