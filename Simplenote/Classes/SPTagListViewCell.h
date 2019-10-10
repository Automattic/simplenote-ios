#import <UIKit/UIKit.h>


@class SPTagListViewCell;

@protocol SPTagListViewCellDelegate <NSObject>

@required
- (void)tagListViewCellShouldDeleteTag:(SPTagListViewCell *)cell;
- (void)tagListViewCellShouldRenameTag:(SPTagListViewCell *)cell;
@end


@interface SPTagListViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField          *tagNameTextField;
@property (nonatomic, strong) IBOutlet UIImageView          *leftImageView;
@property (nonatomic, weak) id<SPTagListViewCellDelegate>   delegate;

@end
