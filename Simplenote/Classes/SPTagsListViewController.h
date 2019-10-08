#import <UIKit/UIKit.h>
#import "SPTagListViewCell.h"
#import "SPSidebarViewController.h"

@class SPButton;
@class SPBorderedView;

@interface SPTagsListViewController : SPSidebarViewController {

    UIView *headerSeparator;
    UIView *footerSeparator;
    UIButton *allNotesButton;
    UIButton *trashButton;
    UIButton *settingsButton;
    UIButton *editTagsButton;
    UILabel *tagsLabel;
    SPBorderedView *customView;
}

@end
