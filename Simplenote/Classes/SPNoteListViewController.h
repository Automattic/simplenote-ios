#import <UIKit/UIKit.h>
#import "SPTransitionController.h"
#import "SPSidebarContainerViewController.h"
#import "Note.h"

@class SPEmptyListView;
@class SPBlurEffectView;
@class SPSearchResultsController;

typedef NS_ENUM(NSInteger, SPTagFilterType) {
	SPTagFilterTypeUserTag = 0,
	SPTagFilterTypeDeleted = 1,
    SPTagFilterTypeUntagged = 2
};

@interface SPNoteListViewController : UIViewController<SPSidebarContainerDelegate> {

    NSTimer *searchTimer;

    // Bools
    BOOL bSearching;
    BOOL bListViewIsEmpty;
    BOOL bIndexingNotes;
    BOOL bShouldShowSidePanel;
}

@property (nonatomic, strong) SPSearchResultsController                     *resultsController;
@property (nonatomic, strong) NSString                                      *searchText;
@property (nonatomic) BOOL                                                  firstLaunch;

@property (nonatomic, strong, readonly) SPBlurEffectView                    *navigationBarBackground;
@property (nonatomic, strong, readonly) UISearchBar                         *searchBar;
@property (nonatomic, assign) SPTagFilterType                               tagFilterType;
@property (nonatomic, strong, readonly) SPEmptyListView                     *emptyListView;
@property (nonatomic, strong, readonly) UITableView                         *tableView;

- (Note *)noteForKey:(NSString *)key;
- (void)update;
- (void)openNote:(Note *)note fromIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)setWaitingForIndex:(BOOL)waiting;
- (void)endSearching;

@end
