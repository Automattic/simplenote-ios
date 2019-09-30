#import "SPNoteListViewController.h"
#import "SPOptionsViewController.h"
#import "SPNavigationController.h"
#import "SPNoteEditorViewController.h"

#import "SPAppDelegate.h"
#import "SPBorderedTableView.h"
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

#import "NSMutableAttributedString+Styling.h"
#import "NSString+Search.h"
#import "NSTextStorage+Highlight.h"
#import "UIBarButtonItem+Images.h"
#import "UIDevice+Extensions.h"
#import "UIImage+Colorization.h"
#import "VSThemeManager.h"

#import <Simperium/Simperium.h>
#import "Simplenote-Swift.h"

@import WordPress_AppbotX;


@interface SPNoteListViewController () <ABXPromptViewDelegate,
                                        ABXFeedbackViewControllerDelegate,
                                        UITableViewDataSource,
                                        UITableViewDelegate,
                                        NSFetchedResultsControllerDelegate,
                                        UIGestureRecognizerDelegate,
                                        UISearchBarDelegate,
                                        UITextFieldDelegate,
                                        SPTransitionControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem           *addButton;
@property (nonatomic, strong) UIBarButtonItem           *sidebarButton;
@property (nonatomic, strong) UIBarButtonItem           *emptyTrashButton;

@property (nonatomic, strong) UISearchController        *searchController;
@property (nonatomic, strong) UISearchBar               *searchBar;
@property (nonatomic, strong) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic, strong) SPTransitionController    *transitionController;
@property (nonatomic, assign) CGFloat                   keyboardHeight;

@property (nonatomic, strong) UIImage                   *panImageDelete;
@property (nonatomic, strong) UIImage                   *panImageRestore;

@end

@implementation SPNoteListViewController

- (instancetype)initWithSidebarViewController:(SPSidebarViewController *)sidebarViewController {
    
    self = [super initWithSidebarViewController:sidebarViewController];
    if (self) {
        [self configureTableView];
        [self configureRootView];
        [self configureNavigationButtons];
        [self configureSearchController];
        [self updateRowHeight];
        [self startListeningToNotifications];

        _panImageDelete = [[UIImage imageNamed:@"icon_cell_pan_trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _panImageRestore = [[UIImage imageNamed:@"icon_cell_pan_restore"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        // add empty list view
        _emptyListView = [[SPEmptyListView alloc] initWithImage:[UIImage imageNamed:@"logo_login"]
                                                       withText:nil];
        
        _emptyListView.frame = self.view.bounds;
        _emptyListView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _emptyListView.userInteractionEnabled = false;

        [self registerForPeekAndPop];
        [self update];
    }
    
    return self;
}


#pragma mark - View Lifecycle

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.searchBar removeBottomSeparatorOnIOS12AndBelow];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showRatingViewIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (![SPAppDelegate sharedDelegate].simperium.user) {
        [self setWaitingForIndex:YES];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

    if (@available(iOS 13.0, *)) {
        if ([previousTraitCollection hasDifferentColorAppearanceComparedToTraitCollection:self.traitCollection] == false) {
            return;
        }

        [self themeDidChange];
    }
}

- (void)updateRowHeight {
        
    CGFloat verticalPadding = [[[VSThemeManager sharedManager] theme] floatForKey:@"noteVerticalPadding"];
    CGFloat topTextViewPadding = verticalPadding;

    CGFloat numberLines = [[Options shared] numberOfPreviewLines];
    CGFloat lineHeight = [[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] lineHeight];

    self.tableView.rowHeight = ceilf(2.5 * verticalPadding + 2 * topTextViewPadding + lineHeight * numberLines);
    
    [self.tableView reloadData];
}


#pragma mark - Notifications

- (void)startListeningToNotifications {

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    // Dynamic Fonts!
    [nc addObserver:self selector:@selector(contentSizeWasUpdated:) name:UIContentSizeCategoryDidChangeNotification object:nil];

    // Condensed Notes
    [nc addObserver:self selector:@selector(condensedPreferenceWasUpdated:) name:SPCondensedNoteListPreferenceChangedNotification object:nil];
    [nc addObserver:self selector:@selector(sortOrderPreferenceWasUpdated:) name:SPNotesListSortModeChangedNotification object:nil];

    // Voiceover status is tracked because the custom animated transition is not used when enabled
    [nc addObserver:self selector:@selector(didReceiveVoiceoverNotification:) name:UIAccessibilityVoiceOverStatusChanged object:nil];

    // Register for keyboard notifications
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // Themes
    [nc addObserver:self selector:@selector(themeDidChange) name:VSThemeManagerThemeDidChangeNotification object:nil];
}

- (void)condensedPreferenceWasUpdated:(id)sender {

    [self updateRowHeight];
}

- (void)contentSizeWasUpdated:(id)sender {

    [self updateRowHeight];
}

- (void)sortOrderPreferenceWasUpdated:(id)sender {

    [self update];
}

- (void)themeDidChange {
    // Refresh the containerView's backgroundColor
    self.view.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];

    // Refresh the Table's UI
    [self.tableView applyTheme];
    [self.tableView reloadData];

    // Restyle the search bar
    [self.searchBar applySimplenoteStyle];
}

- (void)updateNavigationBar {

    if (tagFilterType == SPTagFilterTypeDeleted) {
        [self.navigationItem setRightBarButtonItem:_emptyTrashButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:_sidebarButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:_addButton animated:YES];
        [self.navigationItem setLeftBarButtonItem:_sidebarButton animated:YES];
    }
}


#pragma mark - Interface Initialization

- (void)configureTableView {
    self.tableView = [[SPBorderedTableView alloc] init];
    _tableView.frame = self.rootView.bounds;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.tableFooterView = [UIView new];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.alwaysBounceVertical = YES;
    [_tableView registerNib:[SPNoteTableViewCell loadNib] forCellReuseIdentifier:[SPNoteTableViewCell reuseIdentifier]];
}

- (void)configureRootView {
    [self.rootView addSubview:_tableView];
}

- (void)configureNavigationButtons {

    /// Button: New Note
    ///
    self.addButton = [UIBarButtonItem barButtonWithImage:[UIImage imageNamed:@"icon_new_note"]
                                          imageAlignment:UIBarButtonImageAlignmentRight
                                                  target:self
                                                selector:@selector(addButtonAction:)];
    _addButton.isAccessibilityElement = YES;
    _addButton.accessibilityLabel = NSLocalizedString(@"New note", nil);
    _addButton.accessibilityHint = NSLocalizedString(@"Create a new note", nil);

    /// Button: Display Tags
    ///
    self.sidebarButton = [UIBarButtonItem barButtonContainingCustomViewWithImage:[UIImage imageNamed:@"icon_tags"]
                                                                  imageAlignment:UIBarButtonImageAlignmentLeft
                                                                          target:self
                                                                        selector:@selector(sidebarButtonAction:)];
    _sidebarButton.isAccessibilityElement = YES;
    _sidebarButton.accessibilityLabel = NSLocalizedString(@"Sidebar", @"UI region to the left of the note list which shows all of a users tags");
    _sidebarButton.accessibilityHint = NSLocalizedString(@"Toggle tag sidebar", @"Accessibility hint used to show or hide the sidebar");

    /// Button: Empty Trash
    ///
    self.emptyTrashButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Empty", @"Verb - empty causes all notes to be removed permenently from the trash")
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(emptyAction:)];
    _emptyTrashButton.isAccessibilityElement = YES;
    _emptyTrashButton.accessibilityLabel = NSLocalizedString(@"Empty trash", @"Remove all notes from the trash");
    _emptyTrashButton.accessibilityHint = NSLocalizedString(@"Remove all notes from trash", nil);
}

- (void)configureSearchController {

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.hidesNavigationBarDuringPresentation = YES;
    _searchController.obscuresBackgroundDuringPresentation = NO;

    self.searchBar = _searchController.searchBar;
    _searchBar.placeholder = NSLocalizedString(@"Search", @"Search UI Placeholder");
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.delegate = self;
    [self.searchBar applySimplenoteStyle];

    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = _searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    } else {
// TODO: FIXME
//            _tableView.tableHeaderView = _searchBar;
    }
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
    
    self.searchBar.text = @"";
    self.searchText = nil;
    [self.searchBar resignFirstResponder];
    
    [self update];
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
}


#pragma mark - SearchBar Delegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)s {
    
    if (bDisableUserInteraction || bListViewIsEmpty)
        return NO;
    
    bSearching = YES;
    
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
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
    [self.searchBar endEditing:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)s {
    [self cancelSearchButtonAction:self.searchBar];
}

- (void)performSearch {

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

    SPNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SPNoteTableViewCell.reuseIdentifier forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(SPNoteTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Note *note = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (!note.preview) {
        [note createPreview];
    }

    UIColor *previewColor = [UIColor colorWithName:UIColorNameNoteBodyFontPreviewColor];

    cell.accessibilityLabel = note.titlePreview;
    cell.accessibilityHint = NSLocalizedString(@"Open note", @"Select a note to view in the note editor");

    cell.accessoryLeftImage = note.published ? [UIImage imageWithName:UIImageNameSharedImage] : nil;
    cell.accessoryRightImage = note.pinned ? [UIImage imageWithName:UIImageNamePinImage] : nil;
    cell.accessoryLeftTintColor = previewColor;
    cell.accessoryRightTintColor = previewColor;

    cell.rendersInCondensedMode = Options.shared.condensedNotesList;
    cell.titleText = note.titlePreview;
    cell.bodyText = note.bodyPreview;

    if (bSearching) {
        UIColor *tintColor = [UIColor colorWithName:UIColorNameTintColor];
        [cell highlightSubstringsMatching:_searchText color:tintColor];
    }
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
	[self.emptyTrashButton setEnabled:NO];
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
    [self refreshTitle];

    if (tagFilterType == SPTagFilterTypeDeleted) {
		[self.emptyTrashButton setEnabled: [self numNotes] > 0];
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
        [appDelegate.selectedTag compare:kSimplenoteTagTrashKey] == NSOrderedSame) {
        
        tagFilterType = SPTagFilterTypeDeleted;
    }
    else {
        
        tagFilterType = SPTagFilterTypeUserTag;
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
                [self configureCell:(SPNoteTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
    
    self.addButton.customView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    self.addButton.enabled = NO;
    self.emptyTrashButton.enabled = NO;
    
    [UIView animateWithDuration:UIKitConstants.animationQuickDuration animations:^{
        self.searchBar.alpha = UIKitConstants.alphaMid;
    }];
    
    bDisableUserInteraction = YES;
    
    [(SPNavigationController *)self.navigationController setDisableRotation:YES];
}

- (void)sidebarWillHide {

    [UIView animateWithDuration:UIKitConstants.animationQuickDuration animations:^{
        self.searchBar.alpha = UIKitConstants.alphaFull;
    }];
}

- (void)sidebarDidHide {
    
    self.tableView.scrollEnabled = YES;
    self.tableView.allowsSelection = !(tagFilterType == SPTagFilterTypeDeleted);
    [self.tableView setBorderVisibile:NO];
    
    self.addButton.customView.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    self.addButton.enabled = YES;
    self.emptyTrashButton.enabled = (tagFilterType == SPTagFilterTypeDeleted && [self numNotes] > 0) || tagFilterType != SPTagFilterTypeDeleted ? YES : NO;

    bDisableUserInteraction = NO;
    [(SPNavigationController *)self.navigationController setDisableRotation:NO];
}


#pragma mark - Index progress

- (void)setWaitingForIndex:(BOOL)waiting {
    
    // if the current tag is the deleted tag, do not show the activity spinner
    if (tagFilterType == SPTagFilterTypeDeleted && waiting) {
        return;
    }
    
    if (waiting && self.navigationItem.titleView == nil && (self.fetchedResultsController.fetchedObjects.count == 0 || _firstLaunch)){
        
        if (!_activityIndicator) {
            _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(SPUserInterface.isDark ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray)];
        }
        
        [_activityIndicator startAnimating];
        bResetTitleView = NO;
        [self animateTitleViewSwapWithNewView:_activityIndicator completion:nil];
        
    } else if (!waiting && self.navigationItem.titleView != nil && !bTitleViewAnimating) {

        [self resetTitleView];

    } else if (!waiting) {
        bResetTitleView = YES;
    }
    
    bIndexingNotes = waiting;

    [self updateViewIfEmpty];
}

- (void)animateTitleViewSwapWithNewView:(UIView *)newView completion:(void (^)())completion {
    
    bTitleViewAnimating = YES;
    [UIView animateWithDuration:UIKitConstants.animationShortDuration animations:^{
        self.navigationItem.titleView.alpha = UIKitConstants.alphaZero;

    } completion:^(BOOL finished) {
        self.navigationItem.titleView = newView;

        [UIView animateWithDuration:UIKitConstants.animationShortDuration animations:^{
            self.navigationItem.titleView.alpha = UIKitConstants.alphaFull;

        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }

            self->bTitleViewAnimating = NO;

            if (self->bResetTitleView) {
                [self resetTitleView];
            }
         }];
     }];
    
}

- (void)resetTitleView {

    [self animateTitleViewSwapWithNewView:nil completion:^{
        self->bResetTitleView = NO;
        [self.activityIndicator stopAnimating];
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
