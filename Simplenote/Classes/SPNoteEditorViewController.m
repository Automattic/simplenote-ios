#import "SPNoteEditorViewController.h"
#import "Note.h"
#import "VSThemeManager.h"
#import "SPAppDelegate.h"
#import "SPNoteListViewController.h"
#import "SPTagView.h"
#import "NSTextStorage+Highlight.h"
#import "SPEditorTextView.h"
#import "SPObjectManager.h"
#import "SPAddCollaboratorsViewController.h"
#import "JSONKit+Simplenote.h"
#import "SPHorizontalPickerView.h"
#import "SPVersionPickerViewCell.h"
#import "SPPopoverContainerViewController.h"
#import "UITextView+Simplenote.h"
#import "SPObjectManager.h"
#import "SPInteractiveTextStorage.h"
#import "SPTracker.h"
#import "NSString+Bullets.h"
#import "SPTransitionController.h"
#import "NSString+Search.h"
#import "SPTextView.h"
#import "NSString+Attributed.h"
#import "SPAcitivitySafari.h"
#import "SPNavigationController.h"
#import "SPMarkdownPreviewViewController.h"
#import "UIDevice+Extensions.h"
#import "SPInteractivePushPopAnimationController.h"
#import "SPActionSheet.h"
#import "Simplenote-Swift.h"
#import "SPConstants.h"

@import SafariServices;


CGFloat const SPSelectedAreaPadding = 20;

@interface SPNoteEditorViewController ()<SPActionSheetDelegate,
                                        SPEditorTextViewDelegate,
                                        SPHorizontalPickerViewDelegate,
                                        SPInteractivePushViewControllerProvider,
                                        SPInteractiveDismissableViewController,
                                        SPTagViewDelegate,
                                        UIActionSheetDelegate,
                                        UIPopoverPresentationControllerDelegate>
// UIKit Components
@property (nonatomic, strong) SPBlurEffectView          *navigationBarBackground;
@property (nonatomic, strong) UILabel                   *searchDetailLabel;
@property (nonatomic, strong) SPTagView                 *tagView;
@property (nonatomic, strong) UIBarButtonItem           *nextSearchButton;
@property (nonatomic, strong) UIBarButtonItem           *prevSearchButton;
@property (nonatomic, strong) UIBarButtonItem           *doneSearchButton;

// Sheets
@property (nonatomic, strong) SPActionSheet             *versionActionSheet;
@property (nonatomic, strong) SPHorizontalPickerView    *versionPickerView;

// Timers
@property (nonatomic, strong) NSTimer                   *saveTimer;
@property (nonatomic, strong) NSTimer                   *guarenteedSaveTimer;

// State
@property (nonatomic, assign) BOOL                      actionSheetVisible;
@property (nonatomic, assign) BOOL                      modified;
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

// if a newly created tag is deleted within a certain time span,
// the tag will be completely deleted - note just removed from the
// current note. This helps prevent against tag spam by mistyping
@property (nonatomic, strong) NSString                  *deletedTagBuffer;

@end

@implementation SPNoteEditorViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        // Editor
        [self configureTextView];
        [self configureBottomView];

        // TagView
        _tagView = _noteEditorTextView.tagView;
        _noteEditorTextView.tagView.tagDelegate = self;

        // Notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backButtonAction:)
                                                     name:SPTransitionControllerPopGestureTriggeredNotificationName
                                                   object:nil];
        
        
        // voiceover status is tracked because the tag view is anchored
        // to the bottom of the screen when voiceover is enabled to allow
        // easier access
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveVoiceOverNotification:)
                                                     name:UIAccessibilityVoiceOverStatusDidChangeNotification
                                                   object:nil];

        // Apply the current style right away!
        [self startListeningToThemeNotifications];
        [self refreshStyle];
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

- (VSTheme *)theme
{
    return [[VSThemeManager sharedManager] theme];
}

- (void)refreshStyle
{    
    UIFont *bodyFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFont *headlineFont = [UIFont preferredFontFor:UIFontTextStyleTitle1 weight:UIFontWeightBold];
    UIColor *fontColor = [UIColor simplenoteNoteHeadlineColor];

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = bodyFont.lineHeight * [self.theme floatForKey:@"noteBodyLineHeightPercentage"];

    _tagView = _noteEditorTextView.tagView;

    self.noteEditorTextView.checklistsFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.noteEditorTextView.checklistsTintColor = [UIColor simplenoteNoteBodyPreviewColor];

    UIKeyboardAppearance keyboardAppearance = SPUserInterface.isDark ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
    self.noteEditorTextView.keyboardAppearance = keyboardAppearance;
    self.tagView.keyboardAppearance = keyboardAppearance;

    UIColor *backgroundColor = self.previewing ? [UIColor simplenoteBackgroundPreviewColor] : [UIColor simplenoteBackgroundColor];
    self.noteEditorTextView.backgroundColor = backgroundColor;
    self.tagView.backgroundColor = backgroundColor;
    self.bottomView.backgroundColor = backgroundColor;
    self.view.backgroundColor = backgroundColor;

    self.noteEditorTextView.interactiveTextStorage.tokens = @{
        SPDefaultTokenName : @{
                NSFontAttributeName : bodyFont,
                NSForegroundColorAttributeName : fontColor,
                NSParagraphStyleAttributeName : paragraphStyle
        },
        SPHeadlineTokenName : @{
                NSFontAttributeName : headlineFont,
                NSForegroundColorAttributeName: fontColor,
        }
    };
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = nil;

    [self configureNavigationBarItems];
    [self configureNavigationBarBackground];
    [self configureRootView];
    [self configureSearchToolbar];
    [self configureLayout];
    [self refreshVoiceoverSupport];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setupNavigationController];
    [self highlightSearchResultsIfNeeded];
    [self startListeningToKeyboardNotifications];

    [self refreshNavigationBarButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    /// Note:
    /// This must happen in viewDidAppear (and not before) because of State Restoration.
    /// Decode happens right after `viewWillAppear`, and this way we get to avoid spurious empty notes.
    ///
    if (!_currentNote) {
        [self newButtonAction:nil];
    } else {
        [_noteEditorTextView processChecklists];
        self.userActivity = [NSUserActivity openNoteActivityFor:_currentNote];
    }

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
    if ((_currentNote.content.length == 0) && !self.actionSheetVisible && !self.isPreviewing) {
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
    if (self.currentNote != nil) {
        [self save];
        [self.noteEditorTextView endEditing:YES];
    }

    [self refreshStyle];
}

- (void)highlightSearchResultsIfNeeded
{
    if (!self.searching || _searchString.length == 0 || self.searchResultRanges) {
        return;
    }
    
    NSString *searchText = _noteEditorTextView.text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        self.searchResultRanges = [searchText rangesForTerms:self.searchString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIColor *tintColor = [UIColor simplenoteTintColor];
            [self.noteEditorTextView.textStorage applyColor:tintColor toRanges:self.searchResultRanges];
            
            NSInteger count = self.searchResultRanges.count;
            
            NSString *searchDetailFormat = count == 1 ? NSLocalizedString(@"%d Result", @"Number of found search results") : NSLocalizedString(@"%d Results", @"Number of found search results");
            self.searchDetailLabel.text = [NSString stringWithFormat:searchDetailFormat, count];
            self.searchDetailLabel.alpha = UIKitConstants.alpha0_0;

            [UIView animateWithDuration:0.3
                             animations:^{
                                 
                                 self.searchDetailLabel.alpha = UIKitConstants.alpha1_0;
                             }];
            
            self.highlightedSearchResultIndex = 0;
            [self highlightSearchResultAtIndex:self.highlightedSearchResultIndex];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self stopListeningToKeyboardNotifications];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self refreshTagEditorOffsetWithCoordinator:coordinator];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

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
    if (!self.tagView.isFirstResponder) {
        return;
    }

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self.tagView scrollEntryFieldToVisible:NO];
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
                                                            action:@selector(highlightNextSearchResult:)];
    self.nextSearchButton.width = 34.0;

    self.prevSearchButton = [[UIBarButtonItem alloc] initWithImage:chevronLeftImage
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(highlightPrevSearchResult:)];
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

- (void)didReceiveVoiceOverNotification:(NSNotification *)notification
{
    [self refreshVoiceoverSupport];
}

- (void)ensureNoteIsVisibleInList
{
    // TODO: This should definitely be handled by the Note List itself. Please!
    SPNoteListViewController *listController = [[SPAppDelegate sharedDelegate] noteListViewController];
    if (_currentNote) {
        
        NSIndexPath *notePath = [listController.notesListController indexPathForObject:_currentNote];
        
        if (![[listController.tableView indexPathsForVisibleRows] containsObject:notePath])
            [listController.tableView scrollToRowAtIndexPath:notePath
                                            atScrollPosition:UITableViewScrollPositionTop
                                                    animated:NO];
    }
}

- (void)backButtonAction:(id)sender
{
    if (self.viewingVersions) {
        return;
    }

    [self endEditing];
    [self ensureEmptyNoteIsDeleted];
    [self ensureNoteIsVisibleInList];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)displayNote:(Note *)note
{
    if (!note) {
        _noteEditorTextView.text = nil;
        return;
    }
    
    _currentNote = note;
    [self.noteEditorTextView scrollToTop];

    // Synchronously set the TextView's contents. Otherwise we risk race conditions with `highlightSearchResults`
    self.noteEditorTextView.attributedText = [note.content attributedString];

    // Push off Checklist Processing to smoothen out push animation
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.noteEditorTextView processChecklists];
    });

    // mark note as read
    note.unread = NO;
    
    // update tags field
    NSArray *tags = note.tagsArray;
    if (tags.count > 0) {
        [_tagView setupWithTagNames:tags];
    } else {
        [_tagView clearAllTags];
    }
    
    self.modified = NO;
    self.previewing = NO;
}

- (void)clearNote
{
    _currentNote = nil;
    _noteEditorTextView.text = @"";
    
    [self endSearching:nil];
    
    [_tagView clearAllTags];
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
    previewViewController.markdownText = [self.noteEditorTextView getPlainTextContent];
    
    return previewViewController;
}

- (BOOL)interactivePushPopAnimationControllerShouldBeginPush:(SPInteractivePushPopAnimationController *)controller touchPoint:(CGPoint)touchPoint
{
    if (!self.currentNote.markdown) {
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
        [self.tagView endEditing:YES];
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

- (void)setSearchString:(NSString *)string {
    
    if (string.length > 0) {
        self.searching = YES;
        _searchString = string;
        self.searchResultRanges = nil;
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

- (void)highlightNextSearchResult:(id)sender {
    
    self.highlightedSearchResultIndex = MIN(self.highlightedSearchResultIndex + 1, self.searchResultRanges.count);
    [self highlightSearchResultAtIndex:self.highlightedSearchResultIndex];
}

- (void)highlightPrevSearchResult:(id)sender {
    
    self.highlightedSearchResultIndex = MAX(0, self.highlightedSearchResultIndex - 1);
    [self highlightSearchResultAtIndex:self.highlightedSearchResultIndex];
}

- (void)highlightSearchResultAtIndex:(NSInteger)index {
    
    NSInteger searchResultCount = self.searchResultRanges.count;
    if (index >= 0 && index < searchResultCount) {
        
        // enable or disbale search result puttons accordingly
        self.prevSearchButton.enabled = index > 0;
        self.nextSearchButton.enabled = index < searchResultCount - 1;
        
        [_noteEditorTextView highlightRange:[(NSValue *)self.searchResultRanges[index] rangeValue]
                           animated:YES
                          withBlock:^(CGRect highlightFrame) {

                              // scroll to block
                              highlightFrame.origin.y += highlightFrame.size.height;
                              [self.noteEditorTextView scrollRectToVisible:highlightFrame animated:YES];
                          }];
    }
}

- (void)endSearching:(id)sender {
    
    if ([sender isEqual:self.doneSearchButton])
        [[SPAppDelegate sharedDelegate].noteListViewController endSearching];
    
    _noteEditorTextView.text = [_noteEditorTextView getPlainTextContent];
    [_noteEditorTextView processChecklists];
    
    _searchString = nil;
    self.searchResultRanges = nil;
    
    [_noteEditorTextView clearHighlights:(sender ? YES : NO)];
    
    self.searching = NO;

    [self.navigationController setToolbarHidden:YES animated:YES];
    self.searchDetailLabel.text = nil;
}


#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Slowly Fade-In the NavigationBar's Blur
    [self.navigationBarBackground adjustAlphaMatchingContentOffsetOf:scrollView];
}


#pragma mark UITextViewDelegate methods

// only called for user changes
// safe to alter text attributes here

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if (self.searching)
        [self endSearching:textView];
    
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


- (void)save
{
	if (_currentNote == nil || self.viewingVersions || [self isDictatingText])
		return;    
    
	if (self.modified || _currentNote.deleted == YES)
	{
        // Update note
        _currentNote.content = [_noteEditorTextView getPlainTextContent];
        _currentNote.modificationDate = [NSDate date];

        // Force an update of the note's content preview in case only tags changed
        [_currentNote createPreview];
        
        
        // Simperum: save
        [[SPAppDelegate sharedDelegate] save];
        [SPTracker trackEditorNoteEdited];
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableNote:_currentNote];
        
        self.modified = NO;
	}
}

- (void)willReceiveNewContent {
    
    self.cursorLocationBeforeRemoteUpdate = [_noteEditorTextView selectedRange].location;
    self.noteContentBeforeRemoteUpdate = [_noteEditorTextView getPlainTextContent];
	
    if (_currentNote != nil && ![_noteEditorTextView.text isEqualToString:@""]) {
        _currentNote.content = [_noteEditorTextView getPlainTextContent];
        [[SPAppDelegate sharedDelegate].simperium saveWithoutSyncing];
    }
}

- (void)didReceiveNewContent {
    
    NSUInteger newLocation = [self newCursorLocation:_currentNote.content
                                             oldText:self.noteContentBeforeRemoteUpdate
                                     currentLocation:self.cursorLocationBeforeRemoteUpdate];
	
	_noteEditorTextView.attributedText = [_currentNote.content attributedString];
    [_noteEditorTextView processChecklists];
	
	NSRange newRange = NSMakeRange(newLocation, 0);
	[_noteEditorTextView setSelectedRange:newRange];
	
	NSArray *tags = _currentNote.tagsArray;
	if (tags.count > 0) {
		[_tagView setupWithTagNames:tags];
    }
}

- (void)didReceiveVersion:(NSString *)version data:(NSDictionary *)data {
    
    if (self.viewingVersions) {
        if (self.noteVersionData == nil) {
            self.noteVersionData = [NSMutableDictionary dictionaryWithCapacity:10];
        }
        NSInteger versionInt = [version integerValue];
        [self.noteVersionData setObject:data forKey:[NSNumber numberWithInteger:versionInt]];
        
        [self.versionPickerView reloadData];
    }
}

- (void)didDeleteCurrentNote {

    NSString *title = NSLocalizedString(@"deleted-note-warning", @"Warning message shown when current note is deleted on another device");
    NSString *cancelTitle = NSLocalizedString(@"Accept", @"Label of accept button on alert dialog");

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addCancelActionWithTitle:cancelTitle handler:^(UIAlertAction *action) {
        [self clearNote];
        [self backButtonAction:nil];
    }];

    [alertController presentFromRootViewController];
}

#pragma mark barButton action methods

- (void)keyboardButtonAction:(id)sender {
    
    [self endEditing];
    [_tagView endEditing:YES];
}

- (void)newButtonAction:(id)sender {

    if (self.currentNote.isBlank) {
        [_noteEditorTextView becomeFirstResponder];
        return;
    }
    
    if ([sender isEqual:self.createNoteButton]) {
        [SPTracker trackEditorNoteCreated];
    }

	NSManagedObjectContext *context = [[SPAppDelegate sharedDelegate] managedObjectContext];
    Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
    newNote.modificationDate = [NSDate date];
    newNote.creationDate = [NSDate date];

    // Set the note's markdown tag according to the global preference (defaults NO for new accounts)
    newNote.markdown = [[Options shared] markdown];

    NSString *filteredTagName = [[SPAppDelegate sharedDelegate] filteredTagName];
    if (filteredTagName.length > 0) {
        [newNote addTag:filteredTagName];
    }
    
    // animate current note off the screen and begin editing new note
    BOOL animateContentView = _noteEditorTextView.text.length;
    
    if (animateContentView) {
        
        CGRect snapshotRect = CGRectMake(0,
                                         _noteEditorTextView.contentInset.top,
                                         self.view.frame.size.width,
                                         _noteEditorTextView.frame.size.height - _noteEditorTextView.contentInset.top);
        UIView *snapshot = [self.noteEditorTextView resizableSnapshotViewFromRect:snapshotRect
                                                 afterScreenUpdates:NO
                                                      withCapInsets:UIEdgeInsetsZero ];

        snapshot.frame = snapshotRect;
        [self.view addSubview:snapshot];
        [self displayNote:newNote];

        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             CGRect newFrame = snapshot.frame;
                             newFrame.origin.y += newFrame.size.height;
                             
                             snapshot.frame = newFrame;

                         } completion:^(BOOL finished) {
                             
                             [snapshot removeFromSuperview];
                             [self.noteEditorTextView becomeFirstResponder];

                         }];

    } else {

        [self displayNote:newNote];
    }
}

- (void)insertChecklistAction:(id)sender {
    [_noteEditorTextView insertOrRemoveChecklist];
    
    [SPTracker trackEditorChecklistInserted];
}

- (void)actionSheet:(SPActionSheet *)actionSheet didSelectItemAtIndex:(NSInteger)index {

    if ([actionSheet isEqual:self.versionActionSheet]) {
        
        self.viewingVersions = NO;
        
        if (index == 0) {
            
            // revert back to current version
            _noteEditorTextView.attributedText = [_currentNote.content attributedString];
        } else {
            
            [SPTracker trackEditorNoteRestored];
            
            self.modified = YES;
            [self save];
        }
        
        [_noteEditorTextView processChecklists];
        // Unload versions and re-enable editor
        [_noteEditorTextView setEditable:YES];
        self.noteVersionData = nil;
        [(SPNavigationController *)self.navigationController setDisableRotation:NO];
    }
    
    [actionSheet dismiss];
}

- (void)actionSheetDidShow:(SPActionSheet *)actionSheet {
    
    self.actionSheetVisible = YES;
}

- (void)actionSheetDidDismiss:(SPActionSheet *)actionSheet {
    
    self.actionSheetVisible = NO;

    if ([actionSheet isEqual:self.versionActionSheet]) {
        self.versionActionSheet = nil;
    }
}


#pragma mark Note Actions

- (void)presentHistoryController
{
    if (![[SPAppDelegate sharedDelegate].simperium.authenticator connected]) {

        NSString *title = NSLocalizedString(@"version-alert-message", @"Error alert message shown when trying to view history of a note without an internet connection");
        NSString *cancelTitle = NSLocalizedString(@"OK", nil);

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addCancelActionWithTitle:cancelTitle handler:nil];
        [alertController presentFromRootViewController];
        return;
    }
    
    [SPTracker trackEditorVersionsAccessed];
    
    [self save];
    
    // get the note version data
    self.viewingVersions = YES;
    self.currentVersion = 0; // reset the version number
    
    [_noteEditorTextView setEditable:NO];
    
    // Request the version data from Simperium
    [[[SPAppDelegate sharedDelegate].simperium bucketForName:@"Note"] requestVersions:30 key:_currentNote.simperiumKey];
    
    
    self.versionPickerView = [[SPHorizontalPickerView alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      self.view.frame.size.width,
                                                                                      200) itemClass:[SPVersionPickerViewCell class]
                                                                  delegate:self];
    
    [self.versionPickerView setSelectedIndex:[NSNumber numberWithInteger:(_currentNote.version.integerValue - [self minimumNoteVersion] - 1)].integerValue];
    
    self.versionActionSheet = [SPActionSheet showActionSheetInView:self.navigationController.view
                                                       withMessage:nil
                                              withContentViewArray:@[self.versionPickerView]
                                              withButtonTitleArray:@[NSLocalizedString(@"Cancel", nil), NSLocalizedString(@"Restore Note", @"Restore a note to a previous version")]
                                                          delegate:self];
    self.versionActionSheet.tapToDismiss = NO;
    self.versionActionSheet.cancelButtonIndex = 0;

    [(SPNavigationController *)self.navigationController setDisableRotation:YES];
}

- (long)minimumNoteVersion {

    NSInteger version = [[_currentNote version] integerValue];
    int numVersions = 30;
    NSInteger minVersion = version - numVersions;
    if (minVersion < 1)
        minVersion = 1;
    
    return minVersion;
}


#pragma mark SPHorizontalPickerView delegate methods

- (NSInteger)numberOfItemsInPickerView:(SPHorizontalPickerView *)pickerView {
    
    NSLog(@"there are %ld versions", _currentNote.version.integerValue - [self minimumNoteVersion]);
    
    return _currentNote.version.integerValue - [self minimumNoteVersion];
}

- (SPHorizontalPickerViewCell *)pickerView:(SPHorizontalPickerView *)pickerView viewForIndex:(NSInteger)index {
    
    SPVersionPickerViewCell *cell = (SPVersionPickerViewCell *)[pickerView dequeueReusableCellforIndex:index];
    
    NSInteger versionInt = index + [self minimumNoteVersion] + 1;
    NSDictionary *versionData = [self.noteVersionData objectForKey:[NSNumber numberWithInteger:versionInt]];
    
    if (versionData != nil) {
        NSDate *versionDate = [NSDate dateWithTimeIntervalSince1970:[(NSString *)[versionData objectForKey:@"modificationDate"] doubleValue]];
        
        NSString *dateText = [_currentNote dateString:versionDate brief:NO];
        
        NSArray *dateComponents = [dateText componentsSeparatedByString:@","];
        
        if (dateComponents.count >= 2) {
            
            [cell setDateText:[(NSString *)dateComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                     timeText:[(NSString *)dateComponents[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            
        } else {
            
            [cell setDateText:dateText timeText:nil];
            
        }

        [cell setActivityIndicatorVisible:NO animated:YES];
        
        cell.accessibilityLabel = dateText;
        cell.accessibilityHint = NSLocalizedString(@"version-cell-accessibility-hint", @"Accessiblity hint describing how to reset the current note to a previous version");
        
    } else {
        
        [cell setActivityIndicatorVisible:YES animated:NO];
        cell.accessibilityLabel = NSLocalizedString(@"version-cell-fetching-accessibility-hint", @"Accessibility hint used when previous versions of a note are being fetched");
    }
    
    
    return cell;
    
}

- (NSString *)titleForPickerView:(SPHorizontalPickerView *)pickerView {
    
    return NSLocalizedString(@"Version", @"Represents a snapshot in time for a note");
}

- (CGFloat)heightForItemInPickerView:(SPHorizontalPickerView *)pickerView {
    
    return 66.0;
}

- (CGFloat)widthForItemInPickerView:(SPHorizontalPickerView *)pickerView {
    
    return 132.0;
}

- (void)pickerView:(SPHorizontalPickerView *)pickerView didSelectItemAtIndex:(NSInteger)index {
    
    NSInteger versionInt = index + [self minimumNoteVersion] + 1;
    if (versionInt == self.currentVersion) {
        return;
    }
    
    self.currentVersion = versionInt;
    NSDictionary *versionData = [self.noteVersionData objectForKey:[NSNumber numberWithInteger:versionInt]];
    NSLog(@"Loading version %ld: %@", (long)versionInt, versionData);
    
	if (versionData != nil) {
        
        UIView *snapshot = [_noteEditorTextView snapshotViewAfterScreenUpdates:NO];
        snapshot.frame = _noteEditorTextView.frame;
        [self.view insertSubview:snapshot aboveSubview:_noteEditorTextView];
        
        _noteEditorTextView.attributedText = [(NSString *)[versionData objectForKey:@"content"] attributedString];
        [_noteEditorTextView processChecklists];
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             
                             snapshot.alpha = 0.0;
                             
                         } completion:^(BOOL finished) {
                             [snapshot removeFromSuperview];
                         }];
	}
    
}


#pragma mark SPAddTagDelegate methods

- (void)tagViewDidChange:(SPTagView *)tagView
{
    // Note: When Voiceover is enabled, the Tags Editor is docked!
    if (self.voiceoverEnabled) {
        return;
    }

    [self.noteEditorTextView scrollToBottomWithAnimation:YES];
}

- (void)tagViewDidBeginEditing:(SPTagView *)tagView
{
    // Note: When Voiceover is enabled, the Tags Editor is docked!
    if (self.voiceoverEnabled) {
        return;
    }

    [self.noteEditorTextView scrollToBottomWithAnimation:YES];
}

- (void)tagView:(SPTagView *)tagView didCreateTagName:(NSString *)tagName
{
    if (![[SPObjectManager sharedManager] tagExists:tagName]) {
        [[SPObjectManager sharedManager] createTagFromString:tagName];
        
        _deletedTagBuffer = tagName;
        [NSTimer scheduledTimerWithTimeInterval:3.5
                                         target:self
                                       selector:@selector(clearDeletedTagBuffer)
                                       userInfo:nil
                                        repeats:NO];
    }
    
    [_currentNote addTag:tagName];
    self.modified = YES;
    [self save];
    
    [SPTracker trackEditorTagAdded];
}

- (BOOL)tagView:(SPTagView *)tagView shouldCreateTagName:(NSString *)tagName {
    
    return ![_currentNote hasTag:tagName];
}

- (void)tagView:(SPTagView *)tagView didRemoveTagName:(NSString *)tagName {
    
    [_currentNote stripTag:tagName];
    self.modified = YES;
    
    NSString *deletedTagBuffer = _deletedTagBuffer;
    if (deletedTagBuffer && [deletedTagBuffer isEqualToString:tagName]) {
        [[SPObjectManager sharedManager] removeTagName:deletedTagBuffer];
        [self clearDeletedTagBuffer];
    }
    
    [self save];
    
	[SPTracker trackEditorTagRemoved];
}

- (void)clearDeletedTagBuffer {
    
    _deletedTagBuffer = nil;
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
