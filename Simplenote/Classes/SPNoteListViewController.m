//
//  SPNoteListViewController.m
//  Simplenote
//
//  Created by Tom Witkin on 7/3/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPNoteListViewController.h"
#import "SPOptionsViewController.h"
#import "SPNavigationController.h"
#import "SPNoteEditorViewController.h"

#import "SPAppDelegate.h"
#import "SPBorderedTableView.h"
#import "SPTableViewCell.h"
#import "SPTransitionController.h"
#import "SPTextView.h"
#import "SPEmptyListView.h"
#import "SPActivityView.h"
#import "SPObjectManager.h"
#import "SPTracker.h"
#import "SPRatingsHelper.h"
#import "SPRatingsPromptView.h"

#import "SPAnimations.h"
#import "SPConstants.h"
#import "Note.h"

#import "NSAttributedString+Styling.h"
#import "NSMutableAttributedString+Styling.h"
#import "NSString+Search.h"
#import "NSTextStorage+Highlight.h"
#import "UIBarButtonItem+Images.h"
#import "UIDevice+Extensions.h"
#import "UIView+Subviews.h"
#import "UIImage+Colorization.h"

#import <Simperium/Simperium.h>
@import WordPress_AppbotX;
#import "Simplenote-Swift.h"

#import "VSThemeManager.h"


@interface SPNoteListViewController () <ABXPromptViewDelegate,
                                        ABXFeedbackViewControllerDelegate,
                                        UITableViewDataSource,
                                        UITableViewDelegate,
                                        NSFetchedResultsControllerDelegate,
                                        UIGestureRecognizerDelegate,
                                        UISearchBarDelegate,
                                        UITextFieldDelegate,
                                        SPTransitionControllerDelegate>

@property (nonatomic, strong) SPTitleView               *searchBarContainer;
@property (nonatomic, strong) SPTransitionController    *transitionController;
@property (nonatomic, assign) CGFloat                   keyboardHeight;

@property (nonatomic, strong) UIImage                   *panImageDelete;
@property (nonatomic, strong) UIImage                   *panImageRestore;

@end

@implementation SPNoteListViewController

- (instancetype)initWithSidebarViewController:(SPSidebarViewController *)sidebarViewController {
    
    self = [super initWithSidebarViewController:sidebarViewController];
    if (self) {
        
        self.tableView = [[SPBorderedTableView alloc] init];
        self.tableView.frame = self.rootView.bounds;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.rootView addSubview:_tableView];

        cellIdentifier = [[VSThemeManager sharedManager] theme].name;
        [self.tableView registerClass:[SPTableViewCell class] forCellReuseIdentifier:cellIdentifier];
        self.tableView.alwaysBounceVertical = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateRowHeight:)
                                                     name:SPCondensedNoteListPreferenceChangedNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateSortOrder:)
                                                     name:SPNotesListSortModeChangedNotification
                                                   object:nil];

        // voiceover status is tracked because the custom animated transition
        // is not used when enabled
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveVoiceoverNotification:)
                                                     name:UIAccessibilityVoiceOverStatusChanged
                                                   object:nil];
        
        // Register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self updateRowHeight:nil];
        
        [self updateNavigationBar];
        
        _panImageDelete = [[UIImage imageNamed:@"icon_cell_pan_trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _panImageRestore = [[UIImage imageNamed:@"icon_cell_pan_restore"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        // add empty list view
        _emptyListView = [[SPEmptyListView alloc] initWithImage:[UIImage imageNamed:@"logo_login"]
                                                       withText:nil];
        
        _emptyListView.frame = self.view.bounds;
        _emptyListView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _emptyListView.userInteractionEnabled = false;

        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(themeDidChange) name:VSThemeManagerThemeDidChangeNotification object:nil];

        [self registerForPeekAndPop];
        [self update];
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showRatingViewIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (![SPAppDelegate sharedDelegate].simperium.user) {
        [self setWaitingForIndex:YES];
    }
}


- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

- (void)themeDidChange {
    // Refresh the containerView's backgroundColor
    self.view.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];
    
    // Use a new cellIdentifier so cells redraw with new theme
    cellIdentifier = [[VSThemeManager sharedManager] theme].name;
    [self.tableView applyTheme];
    [self.tableView reloadData];

    // Restyle the search bar
    [self styleSearchBar];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

#if IS_XCODE_11
    if (@available(iOS 13.0, *)) {
        if ([previousTraitCollection hasDifferentColorAppearanceComparedToTraitCollection:self.traitCollection] == false) {
            return;
        }

        [self themeDidChange];
    }
#endif
}

- (void)styleSearchBar {
    UIImage *background = [[UIImage imageWithName:UIImageNameSearchBarBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 6, 5, 5)];
    [searchBar setSearchFieldBackgroundImage:background
                                    forState:UIControlStateNormal];
    _searchBarContainer.backgroundColor = [UIColor clearColor];

    UIColor *searchBarImageColor = [UIColor colorWithName:UIColorNameSearchBarImageColor];

    [searchBar setImage:[[UIImage imageNamed:@"search_icon"] imageWithOverlayColor:searchBarImageColor]
       forSearchBarIcon:UISearchBarIconSearch
                  state:UIControlStateNormal];

    // Apply font to search field by traversing subviews
    NSArray *searchBarSubviews = [searchBar subviewsRespondingToSelector:@selector(setFont:)];
    UIColor *searchBarFontColor = [UIColor colorWithName:UIColorNameTextColor];

    for (UIView *subview in searchBarSubviews) {
        if ([subview isKindOfClass:[UITextField class]] == false) {
            continue;
        }
        
        [(UITextField *)subview setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
        [(UITextField *)subview setTextColor:searchBarFontColor];
        [(UITextField *)subview setKeyboardAppearance:(SPUserInterface.isDark ?
                                                       UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault)];
    }
}

- (void)updateRowHeight:(id)sender {
    
    BOOL condensedNoteList = [[NSUserDefaults standardUserDefaults] boolForKey:SPCondensedNoteListPref];
    
    CGFloat verticalPadding = [self.theme floatForKey:@"noteVerticalPadding"];
    CGFloat topTextViewPadding = verticalPadding;
    
    CGFloat numberLines = condensedNoteList ? 1.0 : 3.0;
    CGFloat lineHeight = [@"Tommy" sizeWithAttributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}].height;
    
    self.tableView.rowHeight = ceilf(2.5 * verticalPadding + 2 * topTextViewPadding + lineHeight * numberLines);
    
    [self.tableView reloadData];
}

- (void)updateSortOrder:(id)sender {

    [self update];
}

- (void)updateNavigationBar {
    
    if (!addButton) {
        addButton = [UIBarButtonItem barButtonWithImage:[UIImage imageNamed:@"icon_new_note"]
                     imageAlignment:UIBarButtonImageAlignmentRight
                                                 target:self
                                               selector:@selector(addButtonAction:)];
        addButton.accessibilityLabel = NSLocalizedString(@"New note", nil);
        addButton.accessibilityHint =NSLocalizedString(@"Create a new note", nil);
    }
    
    
    if (!sidebarButton) {
        sidebarButton = [UIBarButtonItem barButtonContainingCustomViewWithImage:[UIImage imageNamed:@"icon_tags"]
                                              imageAlignment:UIBarButtonImageAlignmentLeft
                                                 target:self
                                               selector:@selector(sidebarButtonAction:)];
        sidebarButton.isAccessibilityElement = YES;
        sidebarButton.accessibilityLabel = NSLocalizedString(@"Sidebar", @"UI region to the left of the note list which shows all of a users tags");
        sidebarButton.accessibilityHint = NSLocalizedString(@"Toggle tag sidebar", @"Accessibility hint used to show or hide the sidebar");
    }
    
    if (!emptyTrashButton) {
        emptyTrashButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Empty", @"Verb - empty causes all notes to be removed permenently from the trash")
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(emptyAction:)];
        emptyTrashButton.accessibilityLabel = NSLocalizedString(@"Empty trash", @"Remove all notes from the trash");
        emptyTrashButton.accessibilityHint = NSLocalizedString(@"Remove all notes from trash", nil);
        
        UIOffset titleOffset = [UIDevice isPad] ? UIOffsetMake(7, 0) : UIOffsetZero;
        [emptyTrashButton setTitlePositionAdjustment:titleOffset forBarMetrics:UIBarMetricsDefault];
    }
        
    if (!searchBar) {
        // titleView was changed to use autolayout in iOS 11
        if (@available(iOS 11.0, *)) {
            searchBar = [[UISearchBar alloc] init];
            _searchBarContainer = [[SPTitleView alloc] init];
            _searchBarContainer.translatesAutoresizingMaskIntoConstraints = NO;
        } else {
            CGFloat searchBarHeight = 44.0;
            searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      self.view.frame.size.width,
                                                                      searchBarHeight)];
            _searchBarContainer = [[SPTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, searchBarHeight)];
            _searchBarContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
        _searchBarContainer.clipsToBounds = NO;
        searchBar.center = _searchBarContainer.center;
        
        searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        searchBar.searchTextPositionAdjustment = UIOffsetMake(5, 1);
        searchBar.searchBarStyle = UISearchBarStyleMinimal;

        [self styleSearchBar];

        searchBar.delegate = self;
        [_searchBarContainer addSubview:searchBar];
    }
    
    if (bSearching) {
        // Add a Cancel button to the toolbar, only needed for iPads
        if ([UIDevice isPad]) {
            if (!iPadCancelButton) {
                iPadCancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Verb - dismiss the notes search view")
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(cancelSearchButtonAction:)];
            }
            
            [self.navigationItem setRightBarButtonItem:iPadCancelButton animated:YES];
        } else {
           [self.navigationItem setRightBarButtonItem:nil animated:YES];
        }
        
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    } else if (tagFilterType == SPTagFilterTypeDeleted) {
        [self.navigationItem setRightBarButtonItem:emptyTrashButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:sidebarButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:addButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:sidebarButton animated:YES];
    }
    
    self.navigationItem.titleView = _searchBarContainer;
    self.navigationItem.titleView.hidden = NO;
    
    // Title must be set to an empty string because we're using a custom titleView,
    // and otherwise we get odd navigation bar behaviour when pushing view controllers
    // onto the navigation controller after the notes editor.
    self.navigationItem.title = @"";
}


#pragma mark - BarButtonActions

- (void)addButtonAction:(id)sender {
    
    [SPTracker trackListNoteCreated];
    
    // the editor view will create a note. Passing no note ensures that an emty note isn't added
    // to the FRC before the animation occurs
    [self.tableView setEditing:NO];   
    [self openNote:nil fromIndexPath:nil animated:YES];
}

- (void)sidebarButtonAction:(id)sender {
    
    [self.tableView setEditing:NO];
    bShouldShowSidePanel = YES;
    [self toggleSidePanel:nil];
}

- (void)cancelSearchButtonAction:(id)sender {
    
    [self endSearching];
}

- (void)endSearching {
    
    bSearching = NO;
    
    searchBar.text = @"";
    self.searchText = nil;
    [searchBar resignFirstResponder];
    
    [self update];
    
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - SearchBar Delegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)s {
    
    if (bDisableUserInteraction || bListViewIsEmpty)
        return NO;
    
    bSearching = YES;
    
    [self updateNavigationBar];
    [searchBar setShowsCancelButton:YES animated:YES];
    
    [self.tableView reloadData];
    
    return bSearching;
}

- (void)searchBar:(UISearchBar *)s textDidChange:(NSString *)searchText {
 
    self.searchText = s.text;
    
    // Don't search immediately; search a tad later to improve performance of search-as-you-type
    if (searchTimer) {
        [searchTimer invalidate];
    }
    
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                   target:self
                                                 selector:@selector(performSearch)
                                                 userInfo:nil
                                                  repeats:NO];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)s {
    [searchBar endEditing:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)s {
    
    [self cancelSearchButtonAction:searchBar];
}

- (void)performSearch
{
    if (!self.searchText) {
        return;
    }
  
    [SPTracker trackListNotesSearched];
    
    [self updateFetchPredicate];
    [self updateViewIfEmpty];
    if ([self.tableView numberOfRowsInSection:0]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }
    
    [searchTimer invalidate];
    searchTimer = nil;
}



#pragma mark - UITableView Data Source

- (NSInteger)numNotes {
    
    return self.fetchedResultsController.fetchedObjects.count;
}

- (Note *)noteForKey:(NSString *)key {
    
    for (Note *n in self.fetchedResultsController.fetchedObjects) {
        
        if ([n.simperiumKey isEqualToString:key])
            return n;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SPTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell) {
        // this shouldn't be needed, but offscreen collection view cells are sometimes called on
        // and this can lead to an occasional crash
        cell = [[SPTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(SPTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (!note.preview) {
        [note createPreview];
    }
    
    UIColor *previewColor = [UIColor colorWithName:UIColorNameNoteBodyFontPreviewColor];
    NSMutableAttributedString *attributedContent = [[NSMutableAttributedString alloc] initWithString:note.preview];
    [attributedContent addChecklistAttachmentsForColor:previewColor];

    cell.previewView.attributedText = attributedContent;
    cell.previewView.alpha = 1.0;
    
    if (bSearching) {
        UIColor *tintColor = [UIColor colorWithName:UIColorNameTintColor];
        NSArray *ranges = [cell.previewView.text rangesForTerms:_searchText];

        [cell.previewView.textStorage applyColorAttribute:tintColor forRanges:ranges];
    }

    cell.accessoryImage0 = note.pinned ? [[UIImage imageWithName:UIImageNamePinImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : nil;
    cell.accessoryImage1 = note.published ? [[UIImage imageWithName:UIImageNameSharedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : nil;
    cell.accessoryTintColor0 = previewColor;
    cell.accessoryTintColor1 = previewColor;

    cell.accessibilityLabel = note.titlePreview;
    cell.accessibilityHint = NSLocalizedString(@"Open note", @"Select a note to view in the note editor");
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return !bDisableUserInteraction;
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (NSArray *)tableView:(UITableView*)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (tagFilterType == SPTagFilterTypeDeleted) {
        return [self rowActionsForDeletedNote:note];
    }

    return [self rowActionsForNote:note];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= self.fetchedResultsController.fetchedObjects.count) {
        return;
    }
    
    [[SPRatingsHelper sharedInstance] incrementSignificantEvent];
    
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self openNote:note fromIndexPath:indexPath animated:YES];
}


#pragma mark - Row Actions

- (NSArray<UITableViewRowAction*> *)rowActionsForDeletedNote:(Note *)note {
    UITableViewRowAction *restore = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                       title:NSLocalizedString(@"Restore", @"Restore a note from the trash, markking it as undeleted")
                                                                     handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                         [[SPObjectManager sharedManager] restoreNote:note];
                                                                         [[CSSearchableIndex defaultSearchableIndex] indexSearchableNote:note];
                                                                     }];
    restore.backgroundColor = [UIColor orangeColor];

    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                      title:NSLocalizedString(@"Delete", @"Trash (verb) - the action of deleting a note")
                                                                    handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                        [SPTracker trackListNoteDeleted];
                                                                        [[SPObjectManager sharedManager] permenentlyDeleteNote:note];
                                                                    }];
    delete.backgroundColor = [UIColor redColor];

    return @[delete, restore];
}

- (NSArray<UITableViewRowAction*> *)rowActionsForNote:(Note *)note {
    UITableViewRowAction *trash = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                     title:NSLocalizedString(@"Trash-verb", @"Trash (verb) - the action of deleting a note")
                                                                   handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                       [SPTracker trackListNoteDeleted];
                                                                       [[SPObjectManager sharedManager] trashNote:note];
                                                                       [[CSSearchableIndex defaultSearchableIndex] deleteSearchableNote:note];
                                                                   }];
    trash.backgroundColor = [UIColor colorWithName:UIColorNameDestructiveActionColor];

    NSString *pinText = note.pinned
                            ? NSLocalizedString(@"Unpin", @"Unpin (verb) - the action of Unpinning a note")
                            : NSLocalizedString(@"Pin", @"Pin (verb) - the action of Pinning a note");

    UITableViewRowAction *togglePin = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                   title:pinText
                                                                 handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                     [self togglePinnedNote:note];
                                                                 }];
    togglePin.backgroundColor = [UIColor colorWithName:UIColorNameSecondaryActionColor];

    UITableViewRowAction *share = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                     title:NSLocalizedString(@"Share", @"Share (verb) - the action of Sharing a note")
                                                                   handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                       [self shareNote:note sourceIndexPath:indexPath];
                                                                   }];
    share.backgroundColor = [UIColor colorWithName:UIColorNameTertiaryActionColor];

    return @[trash, togglePin, share];
}

- (void)togglePinnedNote:(Note *)note {
    note.pinned = !note.pinned;
    [[SPAppDelegate sharedDelegate] save];
}

- (void)shareNote:(Note *)note sourceIndexPath:(NSIndexPath *)sourceIndexPath {
    if (note.content == nil) {
        return;
    }

    [SPTracker trackEditorNoteContentShared];

    UIActivityViewController *acv = [[UIActivityViewController alloc] initWithNote:note];

    if ([UIDevice isPad]) {
        acv.modalPresentationStyle = UIModalPresentationPopover;
        acv.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        acv.popoverPresentationController.sourceRect = [self.tableView rectForRowAtIndexPath:sourceIndexPath];
        acv.popoverPresentationController.sourceView = self.tableView;
    }

    [self presentViewController:acv animated:YES completion:nil];
}


#pragma mark - Gestures

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (void)openNote:(Note *)note fromIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {

    [SPTracker trackListNoteOpened];

    SPNoteEditorViewController *editor = [[SPAppDelegate sharedDelegate] noteEditorViewController];
    if (!_transitionController) {
        self.transitionController = [[SPTransitionController alloc] initWithTableView:self.tableView navigationController:self.navigationController];
        self.transitionController.delegate = self;
    }
        
    BOOL isVoiceOverRunning = UIAccessibilityIsVoiceOverRunning();
    self.navigationController.delegate = isVoiceOverRunning ? nil : self.transitionController;
    editor.transitioningDelegate = isVoiceOverRunning ? nil : self.transitionController;

    [editor updateNote:note];

    if (bSearching) {
        [editor setSearchString:_searchText];
    }
    
    self.transitionController.selectedPath = indexPath;
    
    // Failsafe:
    // We were getting (a whole lot!) of crash reports with the exception
    // 'Pushing the same view controller instance more than once is not supported'. This is intended to act
    // as a safety net. Ref. Issue #345
    if ([self.navigationController.viewControllers containsObject:editor]) {
        return;
    }
    
    [self.navigationController pushViewController:editor animated:animated];
}

- (void)emptyAction:(id)sender
{
    NSString *message = NSLocalizedString(@"Are you sure you want to empty the trash? This cannot be undone.", @"Empty Trash Warning");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *cancelText = NSLocalizedString(@"No", @"Cancels Empty Trash Action");
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleCancel handler:nil];
    
    NSString *acceptText = NSLocalizedString(@"Yes", @"Proceeds with the Empty Trash OP");
    UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:acceptText style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self emptyTrash];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:acceptAction];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)emptyTrash
{
    [SPTracker trackListTrashEmptied];
	[[SPObjectManager sharedManager] emptyTrash];
	[emptyTrashButton setEnabled:NO];
    [self updateViewIfEmpty];
}




#pragma mark - NSFetchedResultsController

- (NSArray *)sortDescriptors
{
    NSString *sortKey = nil;
    BOOL ascending = NO;
    SEL sortSelector = nil;

    SortMode mode = [[Options shared] listSortMode];

    switch (mode) {
        case SortModeAlphabeticallyAscending:
            sortKey = @"content";
            ascending = YES;
            sortSelector = @selector(caseInsensitiveCompare:);
            break;
        case SortModeAlphabeticallyDescending:
            sortKey = @"content";
            ascending = NO;
            sortSelector = @selector(caseInsensitiveCompare:);
            break;
        case SortModeCreatedNewest:
            sortKey = @"creationDate";
            ascending = NO;
            break;
        case SortModeCreatedOldest:
            sortKey = @"creationDate";
            ascending = YES;
            break;
        case SortModeModifiedNewest:
            sortKey = @"modificationDate";
            ascending = NO;
            break;
        case SortModeModifiedOldest:
            sortKey = @"modificationDate";
            ascending = YES;
            break;
    }

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending selector:sortSelector];
    NSSortDescriptor *pinnedSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pinned" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:pinnedSortDescriptor, sortDescriptor, nil];
    
    return sortDescriptors;
}

- (void)updateViewIfEmpty {
    
    bListViewIsEmpty = !(self.fetchedResultsController.fetchedObjects.count > 0);
    
    _emptyListView.hidden = !bListViewIsEmpty;    
    [_emptyListView hideImageView:bSearching];
    
    if (bListViewIsEmpty) {
        // set appropriate text
        if (bIndexingNotes || [SPAppDelegate sharedDelegate].bSigningUserOut) {
            [_emptyListView setText:nil];
        } else if (bSearching)
            [_emptyListView setText:NSLocalizedString(@"No Results", @"Message shown when no notes match a search string")];
        else
            [_emptyListView setText:NSLocalizedString(@"No Notes", @"Message shown in note list when no notes are in the current view")];
        
        CGRect _emptyListViewRect = self.view.bounds;
        _emptyListViewRect.origin.y += [self.topLayoutGuide length];
        _emptyListViewRect.size.height -= _emptyListViewRect.origin.y + _keyboardHeight;
        _emptyListView.frame = _emptyListViewRect;
        
        [self.rootView addSubview:_emptyListView];
        
        
    } else {
        [_emptyListView removeFromSuperview];
    }
    
}

- (void)update {
    
    [self updateFetchPredicate];
    
    if (tagFilterType == SPTagFilterTypeDeleted) {
		[emptyTrashButton setEnabled: [self numNotes] > 0];
    }
    
    self.tableView.allowsSelection = !(tagFilterType == SPTagFilterTypeDeleted);
    
    [self updateViewIfEmpty];
    [self updateNavigationBar];
    [self hideRatingViewIfNeeded];
}

- (void)updateFetchPredicate
{
    SPAppDelegate *appDelegate = [SPAppDelegate sharedDelegate];
    if (appDelegate.selectedTag != nil &&
        [appDelegate.selectedTag compare:@"trash"] == NSOrderedSame) {
        
        tagFilterType = SPTagFilterTypeDeleted;
        searchBar.placeholder = NSLocalizedString(@"Trash-noun", nil).lowercaseString;
    }
    else {
        
        tagFilterType = SPTagFilterTypeUserTag;
        searchBar.placeholder = appDelegate.selectedTag;
    }
    
    NSPredicate *predicate = [self fetchPredicate];
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    [[self.fetchedResultsController fetchRequest] setPredicate: predicate];
    [[self.fetchedResultsController fetchRequest] setFetchBatchSize:20];
    [[self.fetchedResultsController fetchRequest] setSortDescriptors:[self sortDescriptors]];
    
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error here
    }
    
    [self.tableView reloadData];
}


- (NSPredicate *)fetchPredicate {
    
    NSMutableArray *predicateList = [NSMutableArray arrayWithCapacity:3];

    [predicateList addObject: [NSPredicate predicateWithFormat: @"deleted == %@", [NSNumber numberWithBool:tagFilterType == SPTagFilterTypeDeleted]]];
    
    if (tagFilterType == SPTagFilterTypeShared)
        [predicateList addObject: [NSPredicate predicateWithFormat: @"systemTags CONTAINS[c] %@", @"shared"]];
    
    if (tagFilterType == SPTagFilterTypePinned)
        [predicateList addObject: [NSPredicate predicateWithFormat:@"systemTags CONTAINS[c] %@", @"pinned"]];
    
    if (tagFilterType == SPTagFilterTypeUnread)
        [predicateList addObject: [NSPredicate predicateWithFormat:@"systemTags CONTAINS[c] %@", @"unread"]];
    
	SPAppDelegate *appDelegate = [SPAppDelegate sharedDelegate];
    if (tagFilterType == SPTagFilterTypeUserTag && appDelegate.selectedTag.length > 0) {
        
        // Match against "tagName" (JSON formatted)
        NSString *tagName = appDelegate.selectedTag;
        
        tagName = [tagName stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
        tagName = [tagName stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
        
        // individual tags are surrounded by quotes, thus adding quotes to the selected tag
        // ensures only the correct notes are shown
        NSString *match = [[NSString alloc] initWithFormat:@"\"%@\"", tagName];
        [predicateList addObject: [NSPredicate predicateWithFormat: @"tags CONTAINS[c] %@",match]];
    }
    
    if (self.searchText.length > 0) {
        NSArray *searchStrings = [self.searchText componentsSeparatedByString:@" "];
        for (NSString *word in searchStrings) {
            if (word.length == 0)
                continue;
            [predicateList addObject: [NSPredicate predicateWithFormat:@"content CONTAINS[c] %@", word]];
        }
    }
    
    NSPredicate *compound = [NSCompoundPredicate andPredicateWithSubpredicates:predicateList];
    
    return compound;
}


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    // Set appDelegate here because this might get called before it gets an opportunity to be set previously
    SPAppDelegate *appDelegate = [SPAppDelegate sharedDelegate];
    
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:appDelegate.simperium.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Don't fetch deleted notes.
    NSPredicate *predicate = [self fetchPredicate];
    [fetchRequest setPredicate: predicate];
    
    // Edit the sort key as appropriate.
    NSArray *sortDescriptors = [self sortDescriptors];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.simperium.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            if (newIndexPath == nil || [indexPath isEqual:newIndexPath])
            {
                // remove current preview
                Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
                note.preview = nil;
                [self configureCell:(SPTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            }
            else
            {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
                
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
            }
            
            break;
        }
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
    
    // update the empty list view
    NSInteger fetchedObjectsCount = self.fetchedResultsController.fetchedObjects.count;
    if ((fetchedObjectsCount > 0 && bListViewIsEmpty) ||
        (!(fetchedObjectsCount > 0) && !bListViewIsEmpty))
        [self updateViewIfEmpty];
}

#pragma mark - SPRootViewContainerDelegate

- (BOOL)shouldShowSidebar {
 
    BOOL showSidePanelOveride = bShouldShowSidePanel;
    bShouldShowSidePanel = NO;

    // Checking for self.tableView.isEditing prevents showing the sidebar when you use swipe to cancel delete/restore.
    return !(self.tableView.dragging || self.tableView.isEditing || bSearching) || showSidePanelOveride;
}

- (void)resetNavigationBar {
    
    [self updateNavigationBar];
}

- (void)sidebarWillShow {
    
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    [self.tableView setBorderVisibile:YES];
    
    addButton.customView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    addButton.enabled = NO;
    emptyTrashButton.enabled = NO;
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         self->searchBar.alpha = 0.5;
                     }];
    
    bDisableUserInteraction = YES;
    
    [(SPNavigationController *)self.navigationController setDisableRotation:YES];
}

- (void)sidebarDidHide {
    
    self.tableView.scrollEnabled = YES;
    self.tableView.allowsSelection = !(tagFilterType == SPTagFilterTypeDeleted);
    [self.tableView setBorderVisibile:NO];
    
    addButton.customView.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    addButton.enabled = YES;
    emptyTrashButton.enabled = (tagFilterType == SPTagFilterTypeDeleted && [self numNotes] > 0) || tagFilterType != SPTagFilterTypeDeleted ? YES : NO;
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         self->searchBar.alpha = 1.0;
                     }];
    
    bDisableUserInteraction = NO;
    [(SPNavigationController *)self.navigationController setDisableRotation:NO];
}

#pragma mark - Index progress

- (void)setWaitingForIndex:(BOOL)waiting {
    
    // if the current tag is the deleted tag, do not show the activity spinner
    if (tagFilterType == SPTagFilterTypeDeleted && waiting)
        return;
    
    if (waiting && self.navigationItem.titleView != activityIndicator && (self.fetchedResultsController.fetchedObjects.count == 0 || _firstLaunch)){
        
        if (!activityIndicator)
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(SPUserInterface.isDark ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray)];
        
        [activityIndicator startAnimating];
        bResetTitleView = NO;
        [self animateTitleViewSwapWithNewView:activityIndicator
                                   completion:nil];
        
    } else if (!waiting && self.navigationItem.titleView != _searchBarContainer && !bTitleViewAnimating) {
        
        [self resetTitleView];
        
    } else if (!waiting) {
        bResetTitleView = YES;
    }
    
    bIndexingNotes = waiting;

    [self updateViewIfEmpty];
}

- (void)animateTitleViewSwapWithNewView:(UIView *)newView completion:(void (^)())completion {
    
    bTitleViewAnimating = YES;
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.navigationItem.titleView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         
                         self.navigationItem.titleView = newView;
                         
                         [UIView animateWithDuration:0.25
                                          animations:^{
                                              self.navigationItem.titleView.alpha = 1.0;
                                          } completion:^(BOOL finished) {
                                              
                                              if (completion)
                                                  completion();
                                              
                                              self->bTitleViewAnimating = NO;
                                              
                                              if (self->bResetTitleView)
                                                  [self resetTitleView];
                                              
                                          }];
                     }];
    
}

- (void)resetTitleView {
    
    [self animateTitleViewSwapWithNewView:_searchBarContainer
                               completion:^{
                                   self->bResetTitleView = NO;
                                   [self->activityIndicator stopAnimating];
                               }];
    
}

#pragma mark - VoiceOver

- (void)didReceiveVoiceoverNotification:(NSNotification *)notification {
    
    BOOL isVoiceOverRunning = UIAccessibilityIsVoiceOverRunning();
    self.navigationController.delegate = isVoiceOverRunning ? nil : self.transitionController;
	
	SPNoteEditorViewController *editor = [[SPAppDelegate sharedDelegate] noteEditorViewController];
    editor.transitioningDelegate = isVoiceOverRunning ? nil : self.transitionController;
    
}

#pragma mark - SPTransitionDelegate

- (void)interactionBegan {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect keyboardFrame = [(NSValue *)[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _keyboardHeight = MIN(keyboardFrame.size.height, keyboardFrame.size.width);
    
    UIEdgeInsets tableviewInsets = self.tableView.contentInset;
    tableviewInsets.bottom += _keyboardHeight;
    self.tableView.contentInset = tableviewInsets;
    
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    scrollInsets.bottom += _keyboardHeight;
    self.tableView.scrollIndicatorInsets = tableviewInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    _keyboardHeight = 0;
    
    UIEdgeInsets tableviewInsets = self.tableView.contentInset;
    tableviewInsets.bottom = [[self bottomLayoutGuide] length];
    self.tableView.contentInset = tableviewInsets;
    
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    scrollInsets.bottom = [[self bottomLayoutGuide] length];;
    self.tableView.scrollIndicatorInsets = tableviewInsets;
}


#pragma mark - Ratings View Helpers

- (void)showRatingViewIfNeeded
{
    if (![[SPRatingsHelper sharedInstance] shouldPromptForAppReview]) {
        return;
    }
    
    [SPTracker trackRatingsPromptSeen];

    // Note:
    // We use a custom Transition between Note List and Note Editor, that takes snapshots of the notes,
    // and moves them to their final positions.
    // Let's fade in the Ratings Reminder once the transition is ready
    //
    UIView *ratingsView = self.tableView.tableHeaderView ?: [self newAppRatingView];
    ratingsView.alpha = kSimplenoteAnimationInvisibleAlpha;

    [UIView animateWithDuration:kSimplenoteAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                                    // Animate both, Alpha + Rows Sliding
                                    ratingsView.alpha = kSimplenoteAnimationVisibleAlpha;
                                    self.tableView.tableHeaderView = ratingsView;
                                }
                     completion:nil];
}

- (void)hideRatingViewIfNeeded
{
    if (self.tableView.tableHeaderView == nil || [[SPRatingsHelper sharedInstance] shouldPromptForAppReview] == YES) {
        return;
    }
    
    [UIView animateWithDuration:kSimplenoteAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tableView.tableHeaderView = nil;
    } completion:^(BOOL success) {
    }];
}

- (UIView *)newAppRatingView
{
    SPRatingsPromptView *appRatingView = [[SPRatingsPromptView alloc] initWithWidth:CGRectGetWidth(self.view.bounds)];
    appRatingView.label.text = NSLocalizedString(@"What do you think about Simplenote?", @"This is the string we display when prompting the user to review the app");
    appRatingView.delegate = self;
    appRatingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    return appRatingView;
}


#pragma mark - ABXPromptViewDelegate

- (void)appbotPromptForReview
{
    [SPTracker trackRatingsAppRated];
    [[UIApplication sharedApplication] openURL:SPCredentials.iTunesReviewURL options:@{} completionHandler:nil];
    [[SPRatingsHelper sharedInstance] ratedCurrentVersion];
    [self hideRatingViewIfNeeded];
}

- (void)appbotPromptForFeedback
{
    [SPTracker trackRatingsFeedbackScreenOpened];
    [ABXFeedbackViewController showFromController:self placeholder:nil delegate:self];
    [[SPRatingsHelper sharedInstance] gaveFeedbackForCurrentVersion];
    [self hideRatingViewIfNeeded];
}

- (void)appbotPromptClose
{
    [SPTracker trackRatingsDeclinedToRate];
    [[SPRatingsHelper sharedInstance] declinedToRateCurrentVersion];
    [self hideRatingViewIfNeeded];
}

- (void)appbotPromptLiked
{
    [SPTracker trackRatingsAppLiked];
    [[SPRatingsHelper sharedInstance] likedCurrentVersion];
}

- (void)appbotPromptDidntLike
{
    [SPTracker trackRatingsAppDisliked];
    [[SPRatingsHelper sharedInstance] dislikedCurrentVersion];
}

- (void)abxFeedbackDidSendFeedback
{
    [SPTracker trackRatingsFeedbackSent];
}

- (void)abxFeedbackDidntSendFeedback
{
    [SPTracker trackRatingsFeedbackDeclined];
}

@end
