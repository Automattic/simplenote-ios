#import "SPNoteListViewController.h"
#import "SPOptionsViewController.h"
#import "SPNavigationController.h"
#import "SPNoteEditorViewController.h"

#import "SPAppDelegate.h"
#import "SPTransitionController.h"
#import "SPTextView.h"
#import "SPEmptyListView.h"
#import "SPActivityView.h"
#import "SPObjectManager.h"
#import "SPTracker.h"
#import "SPRatingsHelper.h"

#import "SPConstants.h"
#import "Note.h"

#import "NSMutableAttributedString+Styling.h"
#import "NSString+Search.h"
#import "NSTextStorage+Highlight.h"
#import "UIBarButtonItem+Images.h"
#import "UIDevice+Extensions.h"
#import "UIImage+Colorization.h"
#import "VSThemeManager.h"

#import <StoreKit/StoreKit.h>
#import <Simperium/Simperium.h>
#import "Simplenote-Swift.h"


@interface SPNoteListViewController () <UITableViewDelegate,
                                        UITextFieldDelegate,
                                        SearchDisplayControllerDelegate,
                                        SearchControllerPresentationContextProvider,
                                        SPTransitionControllerDelegate,
                                        SPRatingsPromptDelegate>

@property (nonatomic, strong) NSTimer                               *searchTimer;

@property (nonatomic, strong) SPBlurEffectView                      *navigationBarBackground;
@property (nonatomic, strong) UIBarButtonItem                       *addButton;
@property (nonatomic, strong) UIBarButtonItem                       *sidebarButton;
@property (nonatomic, strong) UIBarButtonItem                       *emptyTrashButton;

@property (nonatomic, strong) UITableView                           *tableView;

@property (nonatomic, strong) SearchDisplayController               *searchController;
@property (nonatomic, strong) UIActivityIndicatorView               *activityIndicator;

@property (nonatomic, strong) SPTransitionController                *transitionController;
@property (nonatomic, assign) CGFloat                               keyboardHeight;

@property (nonatomic, assign) BOOL                                  bTitleViewAnimating;
@property (nonatomic, assign) BOOL                                  bResetTitleView;
@property (nonatomic, assign) BOOL                                  bIndexingNotes;

@end

@implementation SPNoteListViewController

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self configureNavigationButtons];
        [self configureNavigationBarBackground];
        [self configureTableView];
        [self configureSearchController];
        [self configureSearchStackView];
        [self configureResultsController];
        [self configureRootView];
        [self updateRowHeight];
        [self startListeningToNotifications];
        [self startDisplayingEntities];
        
        // add empty list view
        _emptyListView = [[SPEmptyListView alloc] initWithImage:[UIImage imageNamed:@"logo_login"]
                                                       withText:nil];
        
        _emptyListView.frame = self.view.bounds;
        _emptyListView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _emptyListView.userInteractionEnabled = false;

        [self registerForPeekAndPop];
        [self refreshStyle];
        [self update];
    }
    
    return self;
}


#pragma mark - View Lifecycle

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self refreshTableViewInsets];
    [self updateTableHeaderSize];
    [self ensureFirstRowIsVisibleIfNeeded];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    [self ensureFirstRowIsVisible];
    [self ensureTransitionControllerIsInitialized];
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

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];

    if (@available(iOS 13.0, *)) {
        if ([previousTraitCollection hasDifferentColorAppearanceComparedToTraitCollection:self.traitCollection] == false) {
            return;
        }

        [self themeDidChange];
    }
}


- (void)ensureTransitionControllerIsInitialized
{
    if (_transitionController != nil) {
        return;
    }

    NSAssert(self.tableView != nil, @"tableView should be initialized before this method runs");
    NSAssert(self.navigationController != nil, @"we should be already living within a navigationController before this method can be called");

    self.transitionController = [[SPTransitionController alloc] initWithTableView:self.tableView navigationController:self.navigationController];
    self.transitionController.delegate = self;
}

- (void)updateRowHeight
{
    self.noteRowHeight = SPNoteTableViewCell.cellHeight;
    self.tagRowHeight = SPTagTableViewCell.cellHeight;
    [self.tableView reloadData];
}

- (void)updateTableHeaderSize {
    UIView *headerView = self.tableView.tableHeaderView;
    if (!headerView) {
        return;
    }

    // Old school workaround. tableHeaderView isn't really Autolayout friendly.
    [headerView adjustSizeForCompressedLayout];
    self.tableView.tableHeaderView = headerView;
}


#pragma mark - Overridden Properties

- (UIStatusBarStyle)preferredStatusBarStyle {
    // In iOS <13, whenever the navigationBar is hidden, the system will query the top VC for its preferred bar style.
    // Nuke this the second iOS 13 is the deployment target, which will probably be around 2021?
    return self.navigationController.preferredStatusBarStyle;
}


#pragma mark - Dynamic Properties

- (UISearchBar *)searchBar {
    return _searchController.searchBar;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (_activityIndicator == nil) {
        UIActivityIndicatorViewStyle style = SPUserInterface.isDark ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray;
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    }

    return _activityIndicator;
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
    [nc addObserver:self selector:@selector(didReceiveVoiceoverNotification:) name:UIAccessibilityVoiceOverStatusDidChangeNotification object:nil];

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
    [self refreshStyle];
}

- (void)refreshStyle {
    // Refresh the containerView's backgroundColor
    self.view.backgroundColor = [UIColor simplenoteBackgroundColor];

    // Refresh the Table's UI
    [self.tableView applySimplenotePlainStyle];
    [self.tableView reloadData];

    // Refresh the SearchBar's UI
    [self.searchBar applySimplenoteStyle];
}

- (void)updateNavigationBar {
    UIBarButtonItem *rightButton = (self.isDeletedFilterActive) ? self.emptyTrashButton : self.addButton;

    [self.navigationItem setRightBarButtonItem:rightButton animated:YES];
    [self.navigationItem setLeftBarButtonItem:self.sidebarButton animated:YES];
}


#pragma mark - Interface Initialization

- (void)configureNavigationButtons {
    NSAssert(_addButton == nil, @"_addButton is already initialized!");
    NSAssert(_sidebarButton == nil, @"_sidebarButton is already initialized!");
    NSAssert(_emptyTrashButton == nil, @"_emptyTrashButton is already initialized!");

    /// Button: New Note
    ///
    self.addButton = [UIBarButtonItem barButtonWithImage:[UIImage imageWithName:UIImageNameNewNote]
                                          imageAlignment:UIBarButtonImageAlignmentRight
                                                  target:self
                                                selector:@selector(addButtonAction:)];
    self.addButton.isAccessibilityElement = YES;
    self.addButton.accessibilityLabel = NSLocalizedString(@"New note", nil);
    self.addButton.accessibilityHint = NSLocalizedString(@"Create a new note", nil);

    /// Button: Display Tags
    ///
    self.sidebarButton = [UIBarButtonItem barButtonContainingCustomViewWithImage:[UIImage imageWithName:UIImageNameMenu]
                                                                  imageAlignment:UIBarButtonImageAlignmentLeft
                                                                          target:self
                                                                        selector:@selector(sidebarButtonAction:)];
    self.sidebarButton.isAccessibilityElement = YES;
    self.sidebarButton.accessibilityLabel = NSLocalizedString(@"Sidebar", @"UI region to the left of the note list which shows all of a users tags");
    self.sidebarButton.accessibilityHint = NSLocalizedString(@"Toggle tag sidebar", @"Accessibility hint used to show or hide the sidebar");

    /// Button: Empty Trash
    ///
    self.emptyTrashButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Empty", @"Verb - empty causes all notes to be removed permenently from the trash")
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(emptyAction:)];

    self.emptyTrashButton.isAccessibilityElement = YES;
    self.emptyTrashButton.accessibilityLabel = NSLocalizedString(@"Empty trash", @"Remove all notes from the trash");
    self.emptyTrashButton.accessibilityHint = NSLocalizedString(@"Remove all notes from trash", nil);
}

- (void)configureNavigationBarBackground {
    NSAssert(_navigationBarBackground == nil, @"_navigationBarBackground is already initialized!");

    // What's going on:
    //  -   SPNavigationController.displaysBlurEffect makes sense when every VC in the hierarchy displays blur.
    //  -   Since our UISearchBar lives in our View Hierarchy, the blur cannot be dealt with by the NavigationBar.
    //  -   Therefore we must inject the blur on a VC per VC basis.
    //
    self.navigationBarBackground = [SPBlurEffectView navigationBarBlurView];
}

- (void)configureTableView {
    NSAssert(_tableView == nil, @"_tableView is already initialized!");

    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.alwaysBounceVertical = YES;
    [self.tableView registerNib:[SPNoteTableViewCell loadNib] forCellReuseIdentifier:[SPNoteTableViewCell reuseIdentifier]];
    [self.tableView registerNib:[SPTagTableViewCell loadNib] forCellReuseIdentifier:[SPTagTableViewCell reuseIdentifier]];
    [self.tableView registerNib:[SPSectionHeaderView loadNib] forHeaderFooterViewReuseIdentifier:[SPSectionHeaderView reuseIdentifier]];
}

- (void)configureSearchController {
    NSAssert(_searchController == nil, @"_searchController is already initialized!");

    self.searchController = [SearchDisplayController new];
    self.searchController.delegate = self;
    self.searchController.presenter = self;

    [self.searchBar applySimplenoteStyle];
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

    [SPTracker trackSidebarButtonPresed];
    [[[SPAppDelegate sharedDelegate] sidebarViewController] toggleSidebar];
}


#pragma mark - SPSearchControllerDelegate methods

- (BOOL)searchDisplayControllerShouldBeginSearch:(SearchDisplayController *)controller
{
    [self.notesListController beginSearch];
    [self.tableView reloadData];

    return YES;
}

- (void)searchDisplayController:(SearchDisplayController *)controller updateSearchResults:(NSString *)keyword
{
    // Don't search immediately; search a tad later to improve performance of search-as-you-type
    if (self.searchTimer) {
        [self.searchTimer invalidate];
    }

    NSTimeInterval const delay = 0.2;
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:delay repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self performSearchWithKeyword:keyword];
    }];    
}

- (void)searchDisplayControllerWillBeginSearch:(SearchDisplayController *)controller
{
    // NO-OP
}

- (void)searchDisplayControllerDidEndSearch:(SearchDisplayController *)controller
{
    [self endSearching];
}


#pragma mark - SPSearchControllerPresenter methods

- (UINavigationController *)navigationControllerForSearchDisplayController:(SearchDisplayController *)controller
{
    return self.navigationController;
}


#pragma mark - Search Helpers

- (void)performSearchWithKeyword:(NSString *)keyword
{
    [self.notesListController refreshSearchResultsWithKeyword:keyword];
  
    [SPTracker trackListNotesSearched];
    
    [self refreshListController];
    [self updateViewIfEmpty];
    if ([self.tableView numberOfRowsInSection:0]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:NO];
    }
    
    [self.searchTimer invalidate];
    self.searchTimer = nil;
}

- (void)endSearching
{
    [self.notesListController endSearch];
    [self update];
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Slowly Fade-In the NavigationBar's Blur
    [self.navigationBarBackground adjustAlphaMatchingContentOffsetOf:scrollView];
}


#pragma mark - Public API

- (void)openNoteWithSimperiumKey:(NSString *)simperiumKey animated:(BOOL)animated
{
    Note *note = [self.notesListController noteForSimperiumKey:simperiumKey];
    if (!note) {
        return;
    }

    [self openNote:note fromIndexPath:nil animated:animated];
}

- (void)openNote:(Note *)note fromIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    [SPTracker trackListNoteOpened];

    SPNoteEditorViewController *editor = [[SPAppDelegate sharedDelegate] noteEditorViewController];

    BOOL disableCustomTransition = UIAccessibilityIsVoiceOverRunning() || self.isSearchActive;
    self.navigationController.delegate = disableCustomTransition ? nil : self.transitionController;
    editor.transitioningDelegate = disableCustomTransition ? nil : self.transitionController;

    [editor updateNote:note];

    if (self.isSearchActive) {
        [editor setSearchString:self.searchText];
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


#pragma mark - NoteListController

- (void)updateViewIfEmpty
{    
    BOOL isListEmpty = self.isListEmpty;
    
    _emptyListView.hidden = !isListEmpty;    
    [_emptyListView hideImageView:self.isSearchActive];
    
    if (isListEmpty) {
        // set appropriate text
        if (self.bIndexingNotes || [SPAppDelegate sharedDelegate].bSigningUserOut) {
            [_emptyListView setText:nil];
        } else if (self.isSearchActive)
            [_emptyListView setText:NSLocalizedString(@"No Results", @"Message shown when no notes match a search string")];
        else
            [_emptyListView setText:NSLocalizedString(@"No Notes", @"Message shown in note list when no notes are in the current view")];

        CGRect _emptyListViewRect = self.view.bounds;
        _emptyListViewRect.origin.y += self.view.safeAreaInsets.top;
        _emptyListViewRect.size.height -= _emptyListViewRect.origin.y + _keyboardHeight;
        _emptyListView.frame = _emptyListViewRect;
        
        [self.view addSubview:_emptyListView];
        
        
    } else {
        [_emptyListView removeFromSuperview];
    }
    
}

- (void)update
{
    [self refreshListController];
    [self refreshTitle];
    [self refreshSearchBar];

    BOOL isTrashOnScreen = self.isDeletedFilterActive;
    BOOL isNotEmpty = !self.isListEmpty;

    self.emptyTrashButton.enabled = isTrashOnScreen && isNotEmpty;
    self.tableView.allowsSelection = !isTrashOnScreen;
    
    [self updateViewIfEmpty];
    [self updateNavigationBar];
    [self hideRatingViewIfNeeded];
}


#pragma mark - SPSidebarContainerDelegate

- (BOOL)sidebarContainerShouldDisplaySidebar:(SPSidebarContainerViewController *)sidebarContainer
{
    // Checking for self.tableView.isEditing prevents showing the sidebar when you use swipe to cancel delete/restore.
    return !(self.tableView.dragging || self.tableView.isEditing || self.isSearchActive);
}

- (void)sidebarContainerWillDisplaySidebar:(SPSidebarContainerViewController *)sidebarContainer
{
    self.tableView.scrollEnabled = NO;
    self.tableView.userInteractionEnabled = NO;
    self.searchBar.userInteractionEnabled = NO;

    self.navigationController.navigationBar.userInteractionEnabled = NO;
}

- (void)sidebarContainerDidDisplaySidebar:(SPSidebarContainerViewController *)sidebarContainer
{
    // NO-OP
}

- (void)sidebarContainerWillHideSidebar:(SPSidebarContainerViewController *)sidebarContainer
{
    // NO-OP: The navigationBar's top right button is refreshed via the regular `Update` sequence.
}

- (void)sidebarContainerDidHideSidebar:(SPSidebarContainerViewController *)sidebarContainer
{
    self.tableView.scrollEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
    self.searchBar.userInteractionEnabled = YES;

    self.navigationController.navigationBar.userInteractionEnabled = YES;
}


#pragma mark - Index progress

- (void)setWaitingForIndex:(BOOL)waiting {
    
    // if the current tag is the deleted tag, do not show the activity spinner
    if (self.isDeletedFilterActive && waiting) {
        return;
    }

    if (waiting && self.navigationItem.titleView == nil && (self.isListEmpty || _firstLaunch)){
        [self.activityIndicator startAnimating];
        self.bResetTitleView = NO;
        [self animateTitleViewSwapWithNewView:self.activityIndicator completion:nil];

    } else if (!waiting && self.navigationItem.titleView != nil && !self.bTitleViewAnimating) {
        [self resetTitleView];

    } else if (!waiting) {
        self.bResetTitleView = YES;
    }
    
    self.bIndexingNotes = waiting;

    [self updateViewIfEmpty];
}

- (void)animateTitleViewSwapWithNewView:(UIView *)newView completion:(void (^)())completion {

    self.bTitleViewAnimating = YES;
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

            self.bTitleViewAnimating = NO;

            if (self.bResetTitleView) {
                [self resetTitleView];
            }
         }];
     }];
}

- (void)resetTitleView {

    [self animateTitleViewSwapWithNewView:nil completion:^{
        self.bResetTitleView = NO;
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
    tableviewInsets.bottom = _keyboardHeight;
    self.tableView.contentInset = tableviewInsets;
    
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    scrollInsets.bottom = _keyboardHeight;
    self.tableView.scrollIndicatorInsets = tableviewInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    _keyboardHeight = 0;

    UIEdgeInsets tableviewInsets = self.tableView.contentInset;
    tableviewInsets.bottom = self.view.safeAreaInsets.bottom;
    self.tableView.contentInset = tableviewInsets;
    
    UIEdgeInsets scrollInsets = self.tableView.scrollIndicatorInsets;
    scrollInsets.bottom = self.view.safeAreaInsets.bottom;
    self.tableView.scrollIndicatorInsets = tableviewInsets;
}


#pragma mark - Ratings View Helpers

- (void)showRatingViewIfNeeded
{
    if (![[SPRatingsHelper sharedInstance] shouldPromptForAppReview]) {
        return;
    }
    
    [SPTracker trackRatingsPromptSeen];

    UIView *ratingsView = self.tableView.tableHeaderView ?: [self newRatingsView];

    // Calculate the minimum required dimension
    [ratingsView adjustSizeForCompressedLayout];

    // UITableView will adjust the HeaderView's width. Right afterwards, we'll perform a layout cycle, to avoid glitches
    self.tableView.tableHeaderView = ratingsView;
    [ratingsView layoutIfNeeded];

    // And finally ... FadeIn!
    ratingsView.alpha = UIKitConstants.alphaZero;

    [UIView animateWithDuration:UIKitConstants.animationShortDuration delay:UIKitConstants.animationDelayZero options:UIViewAnimationOptionCurveEaseIn animations:^{
        ratingsView.alpha = UIKitConstants.alphaFull;
        [self.tableView layoutIfNeeded];
    } completion:nil];
}

- (void)hideRatingViewIfNeeded
{
    if (self.tableView.tableHeaderView == nil || [[SPRatingsHelper sharedInstance] shouldPromptForAppReview] == YES) {
        return;
    }
    
    [UIView animateWithDuration:UIKitConstants.animationShortDuration delay:UIKitConstants.animationDelayZero options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.tableView.tableHeaderView = nil;
        [self.tableView layoutIfNeeded];
    } completion:nil];
}

- (UIView *)newRatingsView
{
    SPRatingsPromptView *ratingsView = [SPRatingsPromptView loadFromNib];
    ratingsView.delegate = self;
    return ratingsView;
}


#pragma mark - SPRatingsPromptDelegate

- (void)displayReviewUI
{
    [SKStoreReviewController requestReview];

    [SPTracker trackRatingsAppRated];
    [[SPRatingsHelper sharedInstance] ratedCurrentVersion];
    [self hideRatingViewIfNeeded];
}

- (void)displayFeedbackUI
{
    UIViewController *feedbackViewController = [SPFeedbackManager feedbackViewController];
    feedbackViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:feedbackViewController animated:YES completion:nil];

    [SPTracker trackRatingsFeedbackScreenOpened];
    [[SPRatingsHelper sharedInstance] gaveFeedbackForCurrentVersion];
    [self hideRatingViewIfNeeded];
}

- (void)dismissRatingsUI
{
    [SPTracker trackRatingsDeclinedToRate];
    [[SPRatingsHelper sharedInstance] declinedToRateCurrentVersion];
    [self hideRatingViewIfNeeded];
}

- (void)simplenoteWasLiked
{
    [SPTracker trackRatingsAppLiked];
    [[SPRatingsHelper sharedInstance] likedCurrentVersion];
}

- (void)simplenoteWasDisliked
{
    [SPTracker trackRatingsAppDisliked];
    [[SPRatingsHelper sharedInstance] dislikedCurrentVersion];
}

@end
