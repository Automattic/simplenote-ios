#import <UIKit/UIKit.h>
#import "SPTagListViewCell.h"
#import "SPSidebarViewController.h"
@class SPButton;
@class SPBorderedView;

@interface SPTagsListViewController : SPSidebarViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, SPTagListViewCellDelegate> {

    UIView *headerSeparator;
    UIView *footerSeparator;
    UIButton *allNotesButton;
    UIButton *trashButton;
    UIButton *settingsButton;
    UIButton *editTagsButton;
    UILabel *tagsLabel;
    SPBorderedView *customView;
    
    BOOL bEditing;
    BOOL bVisible;

    NSString *cellIdentifier;
    NSString *cellWithIconIdentifier;
    
    NSTimer *reloadTimer;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)removeKeyboardObservers;

@end
