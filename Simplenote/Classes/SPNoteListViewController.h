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
#import "Note.h"

@class SPEmptyListView;
@class SPTitleView;

typedef enum {
	SPTagFilterTypeUserTag = 0,
	SPTagFilterTypeDeleted = 1,
	SPTagFilterTypeShared = 2,
    SPTagFilterTypePinned = 3,
    SPTagFilterTypeUnread = 4
} SPTagFilterType;

@interface SPNoteListViewController : SPSidebarContainerViewController {
     
    // Navigation Bar
    UIBarButtonItem *addButton;
    UIBarButtonItem *sidebarButton;
    UIBarButtonItem *iPadCancelButton;

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
        
    SPTagFilterType tagFilterType;
}

@property (nonatomic, strong) SPTitleView                           *searchBarContainer;
@property (nonatomic, strong) UISearchBar                           *searchBar;
@property (nonatomic, strong) NSFetchedResultsController<Note *>    *fetchedResultsController;
@property (nonatomic, strong) NSString                              *searchText;
@property (nonatomic) BOOL                                          firstLaunch;

@property (nonatomic, strong) SPEmptyListView                       *emptyListView;
@property (nonatomic, strong) SPBorderedTableView                   *tableView;

- (Note *)noteForKey:(NSString *)key;
- (void)update;
- (void)openNote:(Note *)note fromIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)setWaitingForIndex:(BOOL)waiting;
- (void)endSearching;

@end
