#import <UIKit/UIKit.h>
#import "SPSidebarContainerViewController.h"
#import "Note.h"

@class SPEmptyListView;
@class SPBlurEffectView;
@class NotesListController;
@class SearchDisplayController;

@interface SPNoteListViewController : UIViewController<SPSidebarContainerDelegate>

@property (nonatomic, strong, readonly) SPBlurEffectView                    *navigationBarBackground;
@property (nonatomic, strong, readonly) UISearchBar                         *searchBar;
@property (nonatomic, strong, readonly) SPEmptyListView                     *emptyListView;
@property (nonatomic, strong, readonly) UITableView                         *tableView;
@property (nonatomic, strong, readonly) SearchDisplayController             *searchController;
@property (nonatomic, strong) NotesListController                           *notesListController;
@property (nonatomic) CGFloat                                               noteRowHeight;
@property (nonatomic) CGFloat                                               tagRowHeight;
@property (nonatomic) BOOL                                                  firstLaunch;

- (void)update;
- (void)openNoteWithSimperiumKey:(NSString *)simperiumKey animated:(BOOL)animated;
- (void)openNote:(Note *)note fromIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)setWaitingForIndex:(BOOL)waiting;
- (void)endSearching;
- (void)updateViewIfEmpty;

@end
