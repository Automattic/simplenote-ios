#import <UIKit/UIKit.h>
#import "SPTransitionController.h"
#import "SPSidebarContainerViewController.h"
#import "Note.h"

@class SPEmptyListView;
@class SPBlurEffectView;

@interface SPNoteListViewController : UIViewController<SPSidebarContainerDelegate> {


    // Bools
    BOOL bSearching;
    BOOL bListViewIsEmpty;
    BOOL bIndexingNotes;
    BOOL bShouldShowSidePanel;
}

@property (nonatomic) BOOL                                                  firstLaunch;

@property (nonatomic, strong, readonly) SPBlurEffectView                    *navigationBarBackground;
@property (nonatomic, strong, readonly) UISearchBar                         *searchBar;
@property (nonatomic, strong, readonly) SPEmptyListView                     *emptyListView;
@property (nonatomic, strong, readonly) UITableView                         *tableView;
@property (nonatomic, strong) NotesListController                           *notesListController;

- (Note *)noteForKey:(NSString *)key;
- (void)update;
- (void)openNoteWithSimperiumKey:(NSString *)simperiumKey animated:(BOOL)animated;
- (void)openNote:(Note *)note fromIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)setWaitingForIndex:(BOOL)waiting;
- (void)endSearching;
- (void)updateViewIfEmpty;

@end
