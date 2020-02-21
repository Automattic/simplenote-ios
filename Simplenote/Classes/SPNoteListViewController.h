#import <UIKit/UIKit.h>
#import "SPTransitionController.h"
#import "SPSidebarContainerViewController.h"
#import "Note.h"

@class SPBlurEffectView;
@class SPPlaceholderView;
@class SPSortBar;
@class NotesListController;
@class SearchDisplayController;

@interface SPNoteListViewController : UIViewController<SPSidebarContainerDelegate>

@property (nonatomic, strong, readonly) SPBlurEffectView                    *navigationBarBackground;
@property (nonatomic, strong, readonly) UISearchBar                         *searchBar;
@property (nonatomic, assign, readonly) BOOL                                isIndexingNotes;
@property (nonatomic, strong) UIImpactFeedbackGenerator                     *feedbackGenerator;
@property (nonatomic, strong) SPPlaceholderView                             *placeholderView;
@property (nonatomic, strong) SPSortBar                                     *sortBar;
@property (nonatomic, strong) UITableView                                   *tableView;
@property (nonatomic, strong) UIStackView                                   *searchBarStackView;
@property (nonatomic, strong, readonly) SearchDisplayController             *searchController;
@property (nonatomic, strong) NotesListController                           *notesListController;
@property (nonatomic, weak) UIPopoverPresentationController                 *popoverController;
@property (nonatomic) CGFloat                                               noteRowHeight;
@property (nonatomic) CGFloat                                               tagRowHeight;
@property (nonatomic) CGFloat                                               keyboardHeight;
@property (nonatomic) BOOL                                                  firstLaunch;
@property (nonatomic) BOOL                                                  mustScrollToFirstRow;

- (void)update;
- (void)openNoteWithSimperiumKey:(NSString *)simperiumKey animated:(BOOL)animated;
- (void)openNote:(Note *)note fromIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)setWaitingForIndex:(BOOL)waiting;
- (void)endSearching;

@end
