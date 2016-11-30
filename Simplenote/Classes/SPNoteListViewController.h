//
//  SPNoteListViewController.h
//  Simplenote
//
//  Created by Tom Witkin on 7/3/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPBorderedTableView.h"
#import "SPTransitionController.h"
#import "SPSidebarContainerViewController.h"
@class Note, SPEmptyListView;

typedef enum {
	SPTagFilterTypeUserTag = 0,
	SPTagFilterTypeDeleted = 1,
	SPTagFilterTypeShared = 2,
    SPTagFilterTypePinned = 3,
    SPTagFilterTypeUnread = 4
} SPTagFilterType;

@interface SPNoteListViewController : SPSidebarContainerViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate, UITextFieldDelegate, SPTransitionControllerDelegate> {
     
    // Navigation Bar
    UIBarButtonItem *addButton;
    UIBarButtonItem *sidebarButton;
    
    // the container is only used to limit the width of the search bar.
    UIView *searchBarContainer;
    UISearchBar *searchBar;
    UIBarButtonItem *emptyTrashButton;
        
    UIActivityIndicatorView *activityIndicator;
    
    NSTimer *searchTimer;
    
    // Bools
    BOOL bSearching;
    BOOL bDisableUserInteraction;
    BOOL bListViewIsEmpty;
    BOOL bTitleViewAnimating;
    BOOL bResetTitleView;
    BOOL bIndexingNotes;
    BOOL bShouldShowSidePanel;

    NSString *cellIdentifier;
        
    SPTagFilterType tagFilterType;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic) BOOL firstLaunch;

@property (nonatomic, strong) SPEmptyListView *emptyListView;
@property (nonatomic, strong) SPBorderedTableView *tableView;

- (Note *)noteForKey:(NSString *)key;
- (void)update;
- (void)openNote:(Note *)note fromIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)setWaitingForIndex:(BOOL)waiting;
- (void)endSearching;

@end
