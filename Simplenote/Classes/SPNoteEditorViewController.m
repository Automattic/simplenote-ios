#import "SPNoteEditorViewController.h"
#import "Note.h"
#import "SPAppDelegate.h"
#import "SPNoteListViewController.h"
#import "SPEditorTextView.h"
#import "SPObjectManager.h"
#import "SPAddCollaboratorsViewController.h"
#import "JSONKit+Simplenote.h"
#import "UITextView+Simplenote.h"
#import "SPObjectManager.h"
#import "SPInteractiveTextStorage.h"
#import "SPTracker.h"
#import "NSString+Bullets.h"
#import "SPTransitionController.h"
#import "SPTextView.h"
#import "NSString+Attributed.h"
#import "SPAcitivitySafari.h"
#import "SPNavigationController.h"
#import "SPMarkdownPreviewViewController.h"
#import "SPInteractivePushPopAnimationController.h"
#import "Simplenote-Swift.h"
#import "SPConstants.h"

@import SafariServices;
@import SimplenoteSearch;

CGFloat const SPSelectedAreaPadding = 20;

@interface SPNoteEditorViewController ()<SPEditorTextViewDelegate,
                                        SPInteractivePushViewControllerProvider,
                                        SPInteractiveDismissableViewController,
                                        UIActionSheetDelegate,
                                        UIPopoverPresentationControllerDelegate>
// UIKit Components
@property (nonatomic, strong) SPBlurEffectView          *navigationBarBackground;
@property (nonatomic, strong) UILabel                   *searchDetailLabel;
@property (nonatomic, strong) UIBarButtonItem           *nextSearchButton;
@property (nonatomic, strong) UIBarButtonItem           *prevSearchButton;
@property (nonatomic, strong) UIBarButtonItem           *doneSearchButton;

// Timers
@property (nonatomic, strong) NSTimer                   *saveTimer;
@property (nonatomic, strong) NSTimer                   *guarenteedSaveTimer;

// State
@property (nonatomic, assign) BOOL                      searching;
@property (nonatomic, assign) BOOL                      viewingVersions;

// Remote Updates
@property (nonatomic, assign) NSUInteger                cursorLocationBeforeRemoteUpdate;
@property (nonatomic, strong) NSString                  *noteContentBeforeRemoteUpdate;

// Versions
@property (nonatomic, assign) NSInteger                 currentVersion;
@property (nonatomic, strong) NSMutableDictionary       *noteVersionData;

// Search
@property (nonatomic, assign) NSInteger                 highlightedSearchResultIndex;
@property (nonatomic, strong) NSArray                   *searchResultRanges;
@property (nonatomic, strong) SearchQuery               *searchQuery;

@end

@implementation SPNoteEditorViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype _Nonnull)initWithNote:(Note * _Nonnull)note {
    self = [super init];
    if (self) {
        _note = note;
    }
    
    return self;
}

- (void)configureTextView
{
    _noteEditorTextView = [[SPEditorTextView alloc] init];
    _noteEditorTextView.delegate = self;
    _noteEditorTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    _noteEditorTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _noteEditorTextView.checklistsFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = nil;

    // Editor
    [self configureTextView];

    [self configureNavigationBarItems];
    [self configureNavigationBarBackground];
    [self configureRootView];
    [self configureSearchToolbar];
    [self configureLayout];
    [self configureTagListViewController];
    [self configureInterlinksProcessor];
    
    [self configureTextViewKeyboard];

    [self startListeningToNotifications];
    [self startListeningToThemeNotifications];

    [self refreshStyle];

    [self configureTextViewObservers];
    [self displayNote];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setupNavigationController];
    [self highlightSearchResultsIfNeeded];
    [self startListeningToKeyboardNotifications];

    [self refreshNavigationBarButtons];

    // Async here to make sure all the frames are correct
    dispatch_async(dispatch_get_main_queue(), ^{
        [self restoreScrollPosition];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.userActivity = [NSUserActivity openNoteActivityFor:self.note];
    [self ensureEditorIsFirstResponder];
}

- (void)configureNavigationBarBackground
{
    NSAssert(self.navigationBarBackground == nil, @"NavigationBarBackground was already initialized!");
    self.navigationBarBackground = [SPBlurEffectView navigationBarBlurView];
}

- (void)setupNavigationController
{
    // Note: Our navigationBar *may* be hidden, as per SPSearchController in the Notes List
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:!self.searching animated:YES];
}

- (void)ensureEditorIsFirstResponder
{
    if ((self.note.content.length == 0) && !self.isShowingHistory && !self.isPreviewing) {
        [_noteEditorTextView becomeFirstResponder];
    }
}

- (void)startListeningToThemeNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(themeDidChange) name:SPSimplenoteThemeChangedNotification object:nil];
}

- (void)themeDidChange
{
    [self save];
    [self.noteEditorTextView endEditing:YES];
    [self refreshStyle];
}

- (void)highlightSearchResultsIfNeeded
{
    if (!self.searching || !self.searchQuery || self.searchQuery.isEmpty || self.searchResultRanges) {
        return;
    }
    
    NSString *searchText = _noteEditorTextView.text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        self.searchResultRanges = [self searchResultRangesIn:(searchText ?: @"")
                                                withKeywords:self.searchQuery.keywords];

        dispatch_async(dispatch_get_main_queue(), ^{

            [self showSearchMapWith:self.searchResultRanges];

            UIColor *tintColor = [UIColor simplenoteEditorSearchHighlightColor];
            [self.noteEditorTextView.textStorage applyBackgroundColor:tintColor toRanges:self.searchResultRanges];
            
            NSInteger count = self.searchResultRanges.count;
            
            NSString *searchDetailFormat = count == 1 ? NSLocalizedString(@"%d Result", @"Number of found search results") : NSLocalizedString(@"%d Results", @"Number of found search results");
            self.searchDetailLabel.text = [NSString stringWithFormat:searchDetailFormat, count];
            self.searchDetailLabel.alpha = UIKitConstants.alpha0_0;

            [UIView animateWithDuration:0.3
                             animations:^{
                                 
                                 self.searchDetailLabel.alpha = UIKitConstants.alpha1_0;
                             }];

            [self highlightSearchResultAtIndex:0 animated:YES];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];

    [self saveScrollPosition];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopListeningToKeyboardNotifications];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self refreshTagEditorOffsetWithCoordinator:coordinator];
    [self refreshInterlinkLookupWithCoordinator:coordinator];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

    if (self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass) {
        [self updateInformationControllerPresentation];
    }

    if (@available(iOS 13.0, *)) {
        if (self.traitCollection.userInterfaceStyle == previousTraitCollection.userInterfaceStyle) {
            return;
        }

        // Okay. Let's talk.
        // Whenever `applyStyle` gets called whenever this VC is not really onScreen, it might have issues with SPUserInteface.isDark
        // (since the active traits might not really match the UIWindow's traits).
        //
        // For the above reason, we _must_ listen to Trait Change events, and refresh the style appropriately.
        //
        // Ref. https://github.com/Automattic/simplenote-ios/issues/599
        //
        [self refreshStyle];
    }
}

- (void)refreshTagEditorOffsetWithCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (!self.tagListViewController.isFirstResponder) {
        return;
    }

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.tagListViewController scrollEntryFieldToVisibleAnimated:NO];
    } completion:nil];
}

- (void)configureSearchToolbar
{
    UIImage *chevronRightImage = [UIImage imageWithName:UIImageNameChevronRight];
    UIImage *chevronLeftImage = [UIImage imageWithName:UIImageNameChevronLeft];

    self.doneSearchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(endSearching:)];
    self.doneSearchButton.width += 10.0;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *flexibleSpaceTwo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];

    self.nextSearchButton = [[UIBarButtonItem alloc] initWithImage:chevronRightImage
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(highlightNextSearchResult)];
    self.nextSearchButton.width = 34.0;

    self.prevSearchButton = [[UIBarButtonItem alloc] initWithImage:chevronLeftImage
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(highlightPrevSearchResult)];
    self.prevSearchButton.width = 34.0;
    
    
    self.searchDetailLabel = [[UILabel alloc] init];
    self.searchDetailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.searchDetailLabel.frame = CGRectMake(0, 0, 180, self.searchDetailLabel.font.lineHeight);
    self.searchDetailLabel.textColor = [UIColor simplenoteNoteHeadlineColor];
    self.searchDetailLabel.textAlignment = NSTextAlignmentCenter;
    self.searchDetailLabel.alpha = 0.0;
    UIBarButtonItem *detailButton = [[UIBarButtonItem alloc] initWithCustomView:self.searchDetailLabel];
    
    [self setToolbarItems:@[self.doneSearchButton, flexibleSpace, detailButton, flexibleSpaceTwo, self.prevSearchButton, self.nextSearchButton] animated:NO];
}

- (void)ensureNoteIsVisibleInList
{
    // TODO: This should definitely be handled by the Note List itself. Please!
    // This code is only called in limited amount of cases. It is not called when you press back button in the nav bar.
    // Do we need this code? :thinking:
    SPNoteListViewController *listController = [[SPAppDelegate sharedDelegate] noteListViewController];

    NSIndexPath *notePath = [listController.notesListController indexPathForObject:self.note];

    if (notePath && ![[listController.tableView indexPathsForVisibleRows] containsObject:notePath])
        [listController.tableView scrollToRowAtIndexPath:notePath
                                        atScrollPosition:UITableViewScrollPositionTop
                                                animated:NO];
}

- (void)dismissEditor:(id)sender
{
    if ([self isShowingHistory]) {
        return;
    }

    [self endEditing];
    [self ensureEmptyNoteIsDeleted];
    [self ensureNoteIsVisibleInList];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)displayNote
{
    [self.noteEditorTextView scrollToTop];

    // Synchronously set the TextView's contents. Otherwise we risk race conditions with `highlightSearchResults`
    self.noteEditorTextView.attributedText = [self.note.content attributedString];

    // Push off Checklist Processing to smoothen out push animation
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.noteEditorTextView processChecklists];
    });

    // mark note as read
    self.note.unread = NO;

    self.modified = NO;
    self.previewing = NO;

    [self updateHomeScreenQuickActions];
}

- (void)endEditing
{
    [self.view endEditing:YES];
}

// Bounces a snapshot of the text view to hint to the user how to access
// the Markdown preview.
- (void)bounceMarkdownPreview
{
    UIView *snapshot = [self.noteEditorTextView snapshotViewAfterScreenUpdates:YES];
    [self.view insertSubview:snapshot aboveSubview:self.noteEditorTextView];

    // We want to hint that there's some content on the right. Creating an actual
    // SPMarkdownPreviewViewController is fairly expensive, so we'll fake it by
    // using the plain text content and dimming it out.
    UIView *fakeMarkdownPreviewSnapshot = [self.noteEditorTextView snapshotViewAfterScreenUpdates:YES];
    fakeMarkdownPreviewSnapshot.alpha = 0.3;
    [snapshot addSubview:fakeMarkdownPreviewSnapshot];

    // Offset the fake markdown preview off to the right of the screen
    CGRect frame = snapshot.frame;
    frame.origin.x = CGRectGetWidth(self.view.bounds);
    fakeMarkdownPreviewSnapshot.frame = frame;

    self.noteEditorTextView.hidden = YES;

    CGFloat bounceDistance = -40;

    // Do a nice bounce animation
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            snapshot.transform = CGAffineTransformMakeTranslation(bounceDistance, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            snapshot.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                snapshot.transform = CGAffineTransformMakeTranslation(bounceDistance/2, 0);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    snapshot.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    self.noteEditorTextView.hidden = NO;
                    [snapshot removeFromSuperview];
                }];
            }];
        }];
    }];
}

- (void)refreshNavigationBarButtons
{
    NSMutableArray *buttons = [NSMutableArray array];

    if (self.shouldHideKeyboardButton) {
        [buttons addObject:self.createNoteButton];
    } else {
        [buttons addObject:self.keyboardButton];
    }

    [buttons addObject:self.actionButton];
    [buttons addObject:self.informationButton];

    if (self.isEditingNote) {
        [buttons addObject:self.checklistButton];
    }

    self.navigationItem.rightBarButtonItems = buttons;
}

- (BOOL)shouldHideKeyboardButton
{
    if ([UIDevice isPad]) {
        return YES;
    }
    
    return !self.isKeyboardVisible;
}


#pragma mark - Property Accessors

- (void)setEditingNote:(BOOL)editingNote
{
    _editingNote = editingNote;
    [self refreshNavigationBarButtons];
}

- (void)setIsKeyboardVisible:(BOOL)isKeyboardVisible
{
    _isKeyboardVisible = isKeyboardVisible;
    [self refreshNavigationBarButtons];
}

- (void)setPreviewing:(BOOL)previewing
{
    _previewing = previewing;
    [self refreshStyle];
}


#pragma mark - UIPopoverPresentationControllerDelegate

// The activity sheet breaks when transitioning from a popover to a modal-style
// presentation, so we'll tell it not to change its presentation if the
// view's size class changes.
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - SPInteractivePushViewControllerProvider (Markdown Preview)

- (UIViewController *)nextViewControllerForInteractivePush
{
    SPMarkdownPreviewViewController *previewViewController = [SPMarkdownPreviewViewController new];
    previewViewController.markdownText = [self.noteEditorTextView plainText];
    
    return previewViewController;
}

- (BOOL)interactivePushPopAnimationControllerShouldBeginPush:(SPInteractivePushPopAnimationController *)controller touchPoint:(CGPoint)touchPoint
{
    if (!self.note.markdown) {
        return NO;
    }

    if (!self.noteEditorTextView.isTextSelected) {
        return YES;
    }

    // We'll check if the Push Gesture intersects with the Selected Text's bounds. If so, we'll deny the
    // Push Interaction.
    CGRect selectedSquare = CGRectInset(self.noteEditorTextView.selectedBounds, -SPSelectedAreaPadding, -SPSelectedAreaPadding);
    CGPoint convertedPoint = [self.view convertPoint:touchPoint toView:self.noteEditorTextView];

    return !CGRectContainsPoint(selectedSquare, convertedPoint);
}

- (void)interactivePushPopAnimationControllerWillBeginPush:(SPInteractivePushPopAnimationController *)controller
{
    // This dispatch is to prevent the animations executed when ending editing
    // from happening interactively along with the push on iOS 9.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tagListViewController.view endEditing:YES];
    });
}


#pragma mark - SPInteractiveDismissableViewController

- (BOOL)requiresFirstResponderRestorationBypass
{
    // Whenever an Interactive Dismiss OP kicks off, we're requesting the "First Responder Restoration" mechanism
    // to be overridden.
    // Ref. https://github.com/Automattic/simplenote-ios/issues/600
    return YES;
}


#pragma mark search

- (void)updateWithSearchQuery:(SearchQuery *)searchQuery
{
    if (!searchQuery || searchQuery.isEmpty) {
        return;
    }

    self.searching = YES;
    _searchQuery = searchQuery;
    self.searchResultRanges = nil;
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)highlightNextSearchResult
{
    [self highlightSearchResultAtIndex:(self.highlightedSearchResultIndex + 1) animated:YES];
}

- (void)highlightPrevSearchResult
{
    [self highlightSearchResultAtIndex:(self.highlightedSearchResultIndex - 1) animated:YES];
}

- (void)highlightSearchResultAtIndex:(NSInteger)index animated:(BOOL)animated
{
    NSInteger searchResultCount = self.searchResultRanges.count;

    if (searchResultCount < 1) {
        return;
    }

    index = MIN(index, searchResultCount - 1);
    index = MAX(index, 0);
    self.highlightedSearchResultIndex = index;

    // enable or disbale search result puttons accordingly
    self.prevSearchButton.enabled = index > 0;
    self.nextSearchButton.enabled = index < searchResultCount - 1;

    NSRange targetRange = [(NSValue *)self.searchResultRanges[index] rangeValue];
    [_noteEditorTextView highlightRange:targetRange animated:YES withBlock:^(CGRect highlightFrame) {
        [self.noteEditorTextView scrollRectToVisible:highlightFrame animated:animated];
    }];
}

- (void)endSearching:(id)sender {
    [self hideSearchMap];

    if ([sender isEqual:self.doneSearchButton])
        [[SPAppDelegate sharedDelegate].noteListViewController endSearching];
    
    _noteEditorTextView.text = [_noteEditorTextView plainText];
    [_noteEditorTextView processChecklists];
    
    _searchQuery = nil;
    self.searchResultRanges = nil;
    
    [_noteEditorTextView clearHighlights:(sender ? YES : NO)];
    
    self.searching = NO;

    [self.navigationController setToolbarHidden:YES animated:YES];
    self.searchDetailLabel.text = nil;
}

- (void)ensureSearchIsDismissed
{
    if (self.searching) {
        [self endSearching:_noteEditorTextView];
    }
}


#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Slowly Fade-In the NavigationBar's Blur
    [self.navigationBarBackground adjustAlphaMatchingContentOffsetOf:scrollView];

    // Relocate Interlink Suggestions (if they're even onscreen!)
    [self.interlinkProcessor refreshInterlinkControllerWithNewOffset:scrollView.contentOffset isDragging:scrollView.isDragging];
}


#pragma mark UITextViewDelegate methods

// only called for user changes
// safe to alter text attributes here

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self isShowingHistory]) {
        return NO;
    }

    [self ensureSearchIsDismissed];

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
        
    BOOL appliedAutoBullets = [textView applyAutoBulletsWithReplacementText:text replacementRange:range];
    
    return !appliedAutoBullets;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    
    // Don't allow "3d press" on our checkbox images
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.modified = YES;
    
    [self.saveTimer invalidate];
    self.saveTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                      target:self
                                                    selector:@selector(saveAndSync:)
                                                    userInfo:nil
                                                     repeats:NO];
    self.saveTimer.tolerance = 0.1;
    
    if (!self.guarenteedSaveTimer) {
        self.guarenteedSaveTimer = [NSTimer scheduledTimerWithTimeInterval:21.0
                                                                    target:self
                                                                  selector:@selector(saveAndSync:)
                                                                  userInfo:nil
                                                                   repeats:NO];
        self.guarenteedSaveTimer.tolerance = 1.0;
    }
    
    if([textView.text hasSuffix:@"\n"] && _noteEditorTextView.selectedRange.location == _noteEditorTextView.text.length) {
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CGPoint bottomOffset = CGPointMake(0, self.noteEditorTextView.contentSize.height - self.noteEditorTextView.bounds.size.height);
            if (self.noteEditorTextView.contentOffset.y < bottomOffset.y)
                [self.noteEditorTextView setContentOffset:bottomOffset animated:YES];
        });
    }
    
    [_noteEditorTextView processChecklists];
    [self.interlinkProcessor processInterlinkLookup];
    
    // Ensure we get back to capitalizing sentences instead of Words after autobulleting.
    // See UITextView+Simplenote
    if (_noteEditorTextView.autocapitalizationType != UITextAutocapitalizationTypeSentences) {
        _noteEditorTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        [_noteEditorTextView reloadInputViews];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.editingNote = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.editingNote = NO;

    [self.interlinkProcessor dismissInterlinkLookup];
    [self cancelSaveTimers];
    [self save];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    // When `performsAggressiveLinkWorkaround` is true we'll get link interactions via `receivedInteractionWithURL:`
    if (URL.containsHttpScheme && !_noteEditorTextView.performsAggressiveLinkWorkaround) {
        [self presentSafariViewControllerAtURL:URL];
        return NO;
    }

    if (URL.isSimplenoteURL) {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
        return NO;
    }

    return YES;
}

- (void)textView:(UITextView *)textView receivedInteractionWithURL:(NSURL *)url
{
    /// This API is expected to only be called in iOS (13.0.x, 13.1.x)
    [self presentSafariViewControllerAtURL:url];
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (self.noteEditorTextView.isInserting || self.noteEditorTextView.isDeletingBackward) {
        return;
    }

    [self.interlinkProcessor dismissInterlinkLookup];
}


#pragma mark - SafariViewController Methods

- (void)presentSafariViewControllerAtURL:(NSURL *)url
{
    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:sfvc animated:YES completion:nil];
}

- (BOOL)isDictatingText {
    NSString *inputMethod = _noteEditorTextView.textInputMode.primaryLanguage;
    if (inputMethod != nil) {
        return [inputMethod isEqualToString:@"dictation"];
    }

    return NO;
}


#pragma mark Simperium

- (void)cancelSaveTimers {
    
    [self.saveTimer invalidate];
    self.saveTimer = nil;
    
    [self.guarenteedSaveTimer invalidate];
    self.guarenteedSaveTimer = nil;
}

- (void)saveAndSync:(NSTimer *)timer
{
	[self save];
    [self cancelSaveTimers];
}

- (void)saveIfNeeded
{
    if (self.modified == NO) {
        return;
    }

    [self save];
}

- (void)save
{
    if (self.isShowingHistory || [self isDictatingText]) {
		return;
    }

	if (self.modified || self.note.deleted == YES)
	{
        // Update note
        self.note.content = [_noteEditorTextView plainText];
        self.note.modificationDate = [NSDate date];

        // Force an update of the note's content preview in case only tags changed
        [self.note createPreview];
        
        
        // Simperum: save
        [[SPAppDelegate sharedDelegate] save];
        [SPTracker trackEditorNoteEdited];
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableNote:self.note];
        
        self.modified = NO;

        [self updateHomeScreenQuickActions];
	}
}

- (void)willReceiveNewContent {
    
    self.cursorLocationBeforeRemoteUpdate = [_noteEditorTextView selectedRange].location;
    self.noteContentBeforeRemoteUpdate = [_noteEditorTextView plainText];
	
    if (![_noteEditorTextView.text isEqualToString:@""]) {
        self.note.content = [_noteEditorTextView plainText];
        [[SPAppDelegate sharedDelegate].simperium saveWithoutSyncing];
    }
}

- (void)didReceiveNewContent {
    
    NSUInteger newLocation = [self newCursorLocation:self.note.content
                                             oldText:self.noteContentBeforeRemoteUpdate
                                     currentLocation:self.cursorLocationBeforeRemoteUpdate];
	
	_noteEditorTextView.attributedText = [self.note.content attributedString];
    [_noteEditorTextView processChecklists];
	
	NSRange newRange = NSMakeRange(newLocation, 0);
	[_noteEditorTextView setSelectedRange:newRange];

    [_tagListViewController reload];
}

- (void)didDeleteCurrentNote {

    NSString *title = NSLocalizedString(@"deleted-note-warning", @"Warning message shown when current note is deleted on another device");
    NSString *cancelTitle = NSLocalizedString(@"Accept", @"Label of accept button on alert dialog");

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addCancelActionWithTitle:cancelTitle handler:^(UIAlertAction *action) {
        [self endSearching:nil];
        [self dismissEditor:nil];
    }];

    [alertController presentFromRootViewController];
}

#pragma mark barButton action methods

- (void)keyboardButtonAction:(id)sender {
    
    [self endEditing];
    [self.tagListViewController.view endEditing:YES];
}

- (void)insertChecklistAction:(id)sender {
    [_noteEditorTextView insertOrRemoveChecklist];
    
    [SPTracker trackEditorChecklistInserted];
}

- (NSUInteger)newCursorLocation:(NSString *)newText oldText:(NSString *)oldText currentLocation:(NSUInteger)location
{
	NSUInteger newCursorLocation = location;
    
    // Cases:
    // 0. All text after cursor (and possibly more) was removed ==> put cursor at end
    // 1. Text was added after the cursor ==> no change
    // 2. Text was added before the cursor ==> location advances
    // 3. Text was removed after the cursor ==> no change
    // 4. Text was removed before the cursor ==> location retreats
    // 5. Text was added/removed on both sides of the cursor ==> not handled
    
    NSInteger deltaLength = newText.length - oldText.length;
    
    // Case 0
    if (newText.length < location)
        return newText.length;
    
    BOOL beforeCursorMatches = NO;
    BOOL afterCursorMatches = NO;
    @try {
        beforeCursorMatches = [[oldText substringToIndex:location] compare:[newText substringToIndex:location]] == NSOrderedSame;
        afterCursorMatches = [[oldText substringFromIndex:location] compare:[newText substringFromIndex:location+deltaLength]] == NSOrderedSame;
    } @catch (NSException *e) {
        
    }
    
    // Cases 2 and 4
    if (!beforeCursorMatches && afterCursorMatches) {
        newCursorLocation += deltaLength;
    }
    
    // Cases 1, 3 and 5 have no change
    return newCursorLocation;
}

@end
