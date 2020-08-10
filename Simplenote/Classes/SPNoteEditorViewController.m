#import "SPNoteEditorViewController.h"
#import "Note.h"
#import "VSThemeManager.h"
#import "UIBarButtonItem+Images.h"
#import "SPAppDelegate.h"
#import "SPNoteListViewController.h"
#import "UIButton+Images.h"
#import "SPActivityView.h"
#import "SPTagView.h"
#import "NSTextStorage+Highlight.h"
#import "SPEditorTextView.h"
#import "SPObjectManager.h"
#import "SPAddCollaboratorsViewController.h"
#import "JSONKit+Simplenote.h"
#import "SPHorizontalPickerView.h"
#import "SPVersionPickerViewCell.h"
#import "SPPopoverContainerViewController.h"
#import "SPOutsideTouchView.h"
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
#import "UIViewController+Extensions.h"
#import "SPInteractivePushPopAnimationController.h"
#import "Simplenote-Swift.h"
#import "SPConstants.h"

@import SafariServices;


CGFloat const SPCustomTitleViewHeight               = 44.0f;
CGFloat const SPPaddingiPadCompactWidthPortrait     = 8.0f;
CGFloat const SPPaddingiPadLeading                  = 4.0f;
CGFloat const SPPaddingiPadTrailing                 = -2.0f;
CGFloat const SPPaddingiPhoneLeadingLandscape       = 0.0f;
CGFloat const SPPaddingiPhoneLeadingPortrait        = 8.0f;
CGFloat const SPPaddingiPhoneTrailingLandscape      = 14.0f;
CGFloat const SPPaddingiPhoneTrailingPortrait       = 6.0f;
CGFloat const SPBarButtonYOriginAdjustment          = -1.0f;
CGFloat const SPMultitaskingCompactOneThirdWidth    = 320.0f;
CGFloat const SPBackButtonImagePadding              = -18;
CGFloat const SPBackButtonTitlePadding              = -15;
CGFloat const SPSelectedAreaPadding                 = 20;

@interface SPNoteEditorViewController ()<SPEditorTextViewDelegate,
                                        SPInteractivePushViewControllerProvider,
                                        SPInteractiveDismissableViewController,
                                        UIPopoverPresentationControllerDelegate>
{
    NSUInteger cursorLocationBeforeRemoteUpdate;
    NSString *noteContentBeforeRemoteUpdate;
    BOOL bounceMarkdownPreviewOnActivityViewDismiss;
}

@property (nonatomic, strong) SPBlurEffectView          *navigationBarBackground;
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
        
        // Helpers
        scrollPosition = _noteEditorTextView.contentOffset.y;
        navigationBarTransform = CGAffineTransformIdentity;
        
        bDisableShrinkingNavigationBar = NO;
        
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
        [self applyStyle];
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

    // Note:
    // Disable SmartDashes / Quotes in iOS 11.0, due to a glitch that broke sync. (Fixed in iOS 11.1).
    if (@available(iOS 11.0, *)) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 11.1) {
            _noteEditorTextView.smartDashesType = UITextSmartDashesTypeNo;
            _noteEditorTextView.smartQuotesType = UITextSmartQuotesTypeNo;
        }
    }
}

- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

- (void)applyStyle
{    
    UIFont *bodyFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFont *headlineFont = [UIFont preferredFontFor:UIFontTextStyleTitle1 weight:UIFontWeightBold];
    UIColor *fontColor = [UIColor simplenoteNoteHeadlineColor];

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = bodyFont.lineHeight * [self.theme floatForKey:@"noteBodyLineHeightPercentage"];

    _tagView = _noteEditorTextView.tagView;
    [_tagView applyStyle];

    self.bottomView.backgroundColor = [UIColor simplenoteBackgroundColor];

    self.noteEditorTextView.checklistsFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.noteEditorTextView.checklistsTintColor = [UIColor simplenoteNoteBodyPreviewColor];
    self.noteEditorTextView.backgroundColor = [UIColor simplenoteBackgroundColor];
    self.noteEditorTextView.keyboardAppearance = (SPUserInterface.isDark ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault);

    UIColor *backgroundColor = [UIColor simplenoteBackgroundColor];
    self.noteEditorTextView.backgroundColor = backgroundColor;
    self.view.backgroundColor = backgroundColor;

    _noteEditorTextView.interactiveTextStorage.tokens = @{
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
    [self configureLayout];
    [self refreshVoiceoverSupport];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setupNavigationController];
    [self setBackButtonTitleForSearchingMode: bSearching];
    [self resetNavigationBarToIdentityWithAnimation:NO completion:nil];
    [self sizeNavigationContainer];
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

- (void)setupNavigationController {
    // Note: Our navigationBar *may* be hidden, as per SPSearchController in the Notes List
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:!bSearching animated:YES];
}

- (void)ensureEditorIsFirstResponder
{
    if ((_currentNote.content.length == 0) && !bActionSheetVisible && !self.isPreviewing) {
        [_noteEditorTextView becomeFirstResponder];
    }
}

- (void)startListeningToThemeNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(themeDidChange) name:VSThemeManagerThemeDidChangeNotification object:nil];
}

- (void)themeDidChange {
    [self applyStyle];
}

- (void)highlightSearchResultsIfNeeded
{
    if (!bSearching || _searchString.length == 0 || self.searchResultRanges) {
        return;
    }
    
    NSString *searchText = _noteEditorTextView.text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        self.searchResultRanges = [searchText rangesForTerms:self->_searchString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIColor *tintColor = [UIColor simplenoteTintColor];
            [self.noteEditorTextView.textStorage applyColor:tintColor toRanges:self.searchResultRanges];
            
            NSInteger count = self.searchResultRanges.count;
            
            NSString *searchDetailFormat = count == 1 ? NSLocalizedString(@"%d Result", @"Number of found search results") : NSLocalizedString(@"%d Results", @"Number of found search results");
            self->searchDetailLabel.text = [NSString stringWithFormat:searchDetailFormat, count];
            self->searchDetailLabel.alpha = UIKitConstants.alpha0_0;

            [UIView animateWithDuration:0.3
                             animations:^{
                                 
                                 self->searchDetailLabel.alpha = UIKitConstants.alpha1_0;
                             }];
            
            self->highlightedSearchResultIndex = 0;
            [self highlightSearchResultAtIndex:self->highlightedSearchResultIndex];
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
    [self refreshNavBarSizeWithCoordinator:coordinator];
    [self refreshTagEditorOffsetWithCoordinator:coordinator];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self refreshNavBarSizeWithCoordinator:coordinator];
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
        [self applyStyle];
    }
}

- (void)refreshNavBarSizeWithCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self->bDisableShrinkingNavigationBar = YES;
        [self sizeNavigationContainer];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self->bDisableShrinkingNavigationBar = NO;
    }];
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

- (void)sizeNavigationContainer {
    
    self.navigationItem.titleView.frame = CGRectMake(0, 0, MAX(self.view.frame.size.width, self.view.frame.size.height), SPCustomTitleViewHeight);
    navigationButtonContainer.frame = self.navigationItem.titleView.bounds;

    BOOL isPad = [UIDevice isPad];

    CGFloat leadingPadding = SPPaddingiPhoneLeadingPortrait;
    CGFloat trailingPadding = SPPaddingiPhoneTrailingPortrait;
    
    if (isPad) {
        leadingPadding  = SPPaddingiPadLeading;
        trailingPadding = SPPaddingiPadTrailing;
    } else if (self.isViewVerticallyCompact) {
        leadingPadding  = SPPaddingiPhoneLeadingLandscape;
        trailingPadding = SPPaddingiPhoneTrailingLandscape;
    }
    
    // iPad in portrait split view or landscape 1/3 split requires some extra insets to match the list view
    if (isPad && self.isViewHorizontallyCompact) {
        if (CGRectGetWidth(self.navigationController.view.bounds) == SPMultitaskingCompactOneThirdWidth) {
            leadingPadding += SPPaddingiPadCompactWidthPortrait;
            trailingPadding -= SPPaddingiPadCompactWidthPortrait;
        }
    }
    
    self.backButton.frame = CGRectMake(leadingPadding,
                                       SPBarButtonYOriginAdjustment,
                                       self.backButton.frame.size.width,
                                       navigationButtonContainer.frame.size.height);
    
    CGFloat previousXOrigin = navigationButtonContainer.frame.size.width + trailingPadding;
    CGFloat buttonWidth = [self.theme floatForKey:@"barButtonWidth"];
    CGFloat buttonHeight = buttonWidth;
    
    self.keyboardButton.frame = CGRectMake(previousXOrigin - buttonWidth,
                                           SPBarButtonYOriginAdjustment,
                                           buttonWidth,
                                           buttonHeight);
        
    self.createNoteButton.frame = CGRectMake(previousXOrigin - buttonWidth,
                                             SPBarButtonYOriginAdjustment,
                                             buttonWidth,
                                             buttonHeight);
    
    previousXOrigin = self.createNoteButton.frame.origin.x;
    
    self.actionButton.frame = CGRectMake(previousXOrigin - buttonWidth,
                                         SPBarButtonYOriginAdjustment,
                                         buttonWidth,
                                         buttonHeight);
    
    previousXOrigin = self.actionButton.frame.origin.x;
    
    self.checklistButton.frame = CGRectMake(previousXOrigin - buttonWidth,
                                            SPBarButtonYOriginAdjustment,
                                            buttonWidth,
                                            buttonHeight);
}


- (void)configureNavigationBarItems
{
    // setup Navigation Bar
    self.navigationItem.hidesBackButton = YES;

    // Load Assets
    UIImage *chevronRightImage = [UIImage imageWithName:UIImageNameChevronRight];
    UIImage *chevronLeftImage = [UIImage imageWithName:UIImageNameChevronLeft];

    // container view
    SPOutsideTouchView *titleView = [[SPOutsideTouchView alloc] init];
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    navigationButtonContainer = [[SPOutsideTouchView alloc] init];
    navigationButtonContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [titleView addSubview:navigationButtonContainer];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(navigationBarContainerTapped:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    
    [navigationButtonContainer addGestureRecognizer:tapGesture];
    
    // back button
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setImage:chevronLeftImage forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.backButton.imageEdgeInsets = UIEdgeInsetsMake(0, SPBackButtonImagePadding, 0, 0);
    self.backButton.titleEdgeInsets = UIEdgeInsetsMake(0, SPBackButtonTitlePadding, 0, 0);
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.backButton.accessibilityHint = NSLocalizedString(@"notes-accessibility-hint", @"VoiceOver accessibiliity hint on the button that closes the notes editor and navigates back to the note list");
    [self.backButton addTarget:self
                        action:@selector(backButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [navigationButtonContainer addSubview:self.backButton];
    
    
    // setup right buttons
    self.actionButton = [UIButton buttonWithImage:[UIImage imageWithName:UIImageNameInfo]
                                      target:self
                                    selector:@selector(actionButtonAction:)];
    self.actionButton.accessibilityIdentifier = @"note-menu";
    self.actionButton.accessibilityLabel = NSLocalizedString(@"Menu", @"Terminoligy used for sidebar UI element where tags are displayed");
    self.actionButton.accessibilityHint = NSLocalizedString(@"menu-accessibility-hint", @"VoiceOver accessibiliity hint on button which shows or hides the menu");
    
    self.checklistButton = [UIButton buttonWithImage:[UIImage imageWithName:UIImageNameChecklist]
                                              target:self
                                            selector:@selector(insertChecklistAction:)];
    
    self.createNoteButton = [UIButton buttonWithImage:[UIImage imageWithName:UIImageNameNewNote]
                                               target:self
                                             selector:@selector(newButtonAction:)];
    self.createNoteButton.accessibilityLabel = NSLocalizedString(@"New note", @"Label to create a new note");
    self.createNoteButton.accessibilityHint = NSLocalizedString(@"Create a new note", nil);
    
    self.keyboardButton = [UIButton buttonWithImage:[UIImage imageWithName:UIImageNameHideKeyboard]
                                            target:self
                                          selector:@selector(keyboardButtonAction:)];
    self.keyboardButton.accessibilityLabel = NSLocalizedString(@"Dismiss keyboard", nil);
    
    self.keyboardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    self.createNoteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    self.actionButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    self.checklistButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    
    [navigationButtonContainer addSubview:self.keyboardButton];
    [navigationButtonContainer addSubview:self.createNoteButton];
    [navigationButtonContainer addSubview:self.actionButton];
    [navigationButtonContainer addSubview:self.checklistButton];
    
    [self sizeNavigationContainer];

    self.navigationItem.titleView = titleView;
    
    // setup search toolbar
    doneSearchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                     target:self
                                                                     action:@selector(endSearching:)];
    doneSearchButton.width += 10.0;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *flexibleSpaceTwo = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];

    nextSearchButton = [UIBarButtonItem barButtonWithImage:chevronRightImage
                                            imageAlignment:UIBarButtonImageAlignmentRight
                                                    target:self
                                                  selector:@selector(highlightNextSearchResult:)];
        nextSearchButton.width = 34.0;
    prevSearchButton = [UIBarButtonItem barButtonWithImage:chevronLeftImage
                                            imageAlignment:UIBarButtonImageAlignmentRight
                                                    target:self
                                                  selector:@selector(highlightPrevSearchResult:)];
    prevSearchButton.width = 34.0;
    
    
    searchDetailLabel = [[UILabel alloc] init];
    searchDetailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    searchDetailLabel.frame = CGRectMake(0, 0, 180, searchDetailLabel.font.lineHeight);
    searchDetailLabel.textColor = [UIColor simplenoteNoteHeadlineColor];
    searchDetailLabel.textAlignment = NSTextAlignmentCenter;
    searchDetailLabel.alpha = 0.0;
    UIBarButtonItem *detailButton = [[UIBarButtonItem alloc] initWithCustomView:searchDetailLabel];
    
    
    
    [self setToolbarItems:@[doneSearchButton, flexibleSpace, detailButton, flexibleSpaceTwo, prevSearchButton, nextSearchButton] animated:NO];
    
}

- (void)didReceiveVoiceOverNotification:(NSNotification *)notification
{
    [self refreshVoiceoverSupport];
}

- (void)setBackButtonTitleForSearchingMode:(BOOL)searching{
    NSString *backButtonTitle = searching ? NSLocalizedString(@"Search", @"Using Search instead of Back if user is searching") : NSLocalizedString(@"Notes", @"Plural form of notes");
    [self.backButton setTitle:backButtonTitle
                     forState:UIControlStateNormal];
    self.backButton.accessibilityLabel = backButtonTitle;
    [self.backButton sizeToFit];
}

- (void)prepareToPopView {
    
    [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
    
    [self endEditing:nil];
    
    if (bBlankNote) {
        
        // delete note
        [[SPObjectManager sharedManager] permenentlyDeleteNote:_currentNote];
        _currentNote = nil;
        
    } else {
        [self save];
    }
    
    SPNoteListViewController *listController = [[SPAppDelegate sharedDelegate] noteListViewController];
    if (_currentNote) {
        
        NSIndexPath *notePath = [listController.notesListController indexPathForObject:_currentNote];
        
        if (![[listController.tableView indexPathsForVisibleRows] containsObject:notePath])
            [listController.tableView scrollToRowAtIndexPath:notePath
                                            atScrollPosition:UITableViewScrollPositionTop
                                                    animated:NO];
    }
    
}


- (void)backButtonAction:(id)sender {
    
    // this is to disable the swipe gesture while restoring to a previous version
    if (bViewingVersions) {
        return;
    }
    
    [self prepareToPopView];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [[self.navigationController transitionCoordinator]
         animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {}
         completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            // clear the current note after pop animation completes if it wasn't cancelled
            if (!context.isCancelled) {
                [self clearNote];
            }
         }
     ];
}

- (void)updateNote:(Note *)note {
    
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
    
    [self resetNavigationBarToIdentityWithAnimation:NO completion:nil];
    
    // mark note as read
    note.unread = NO;
    
    // update tags field
    NSArray *tags = note.tagsArray;
    if (tags.count > 0) {
        [_tagView setupWithTagNames:tags];
    } else {
        [_tagView clearAllTags];
    }
    
    bBlankNote = NO;
    bModified = NO;
    self.previewing = NO;
}

- (void)clearNote {
    
    bBlankNote = NO;
    _currentNote = nil;
    _noteEditorTextView.text = @"";
    
    [self endSearching:nil];
    
    [_tagView clearAllTags];
}


- (void)endEditing:(id)sender
{
    [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
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

                    self->bounceMarkdownPreviewOnActivityViewDismiss = NO;
                }];
            }];
        }];
    }];
}

- (void)refreshNavigationBarButtons
{
    BOOL shouldHideKeyboardButton = [self shouldHideKeyboardButton];
    
    self.checklistButton.hidden = !self.isEditingNote;
    self.keyboardButton.hidden = shouldHideKeyboardButton;
    self.createNoteButton.hidden = !shouldHideKeyboardButton;
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


#pragma mark - UIPopoverPresentationControllerDelegate

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    if (bounceMarkdownPreviewOnActivityViewDismiss) {
        [self bounceMarkdownPreview];
    }
}

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

        [self resetNavigationBarToIdentityWithAnimation:YES completion:^{
            self->bDisableShrinkingNavigationBar = YES;
        }];
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
        bSearching = YES;
        _searchString = string;
        self.searchResultRanges = nil;
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

- (void)highlightNextSearchResult:(id)sender {
    
    highlightedSearchResultIndex = MIN(highlightedSearchResultIndex + 1, self.searchResultRanges.count);
    [self highlightSearchResultAtIndex:highlightedSearchResultIndex];
}

- (void)highlightPrevSearchResult:(id)sender {
    
    highlightedSearchResultIndex = MAX(0, highlightedSearchResultIndex - 1);
    [self highlightSearchResultAtIndex:highlightedSearchResultIndex];
}

- (void)highlightSearchResultAtIndex:(NSInteger)index {
    
    NSInteger searchResultCount = self.searchResultRanges.count;
    if (index >= 0 && index < searchResultCount) {
        
        // enable or disbale search result puttons accordingly
        prevSearchButton.enabled = index > 0;
        nextSearchButton.enabled = index < searchResultCount - 1;
        
        [_noteEditorTextView highlightRange:[(NSValue *)self.searchResultRanges[index] rangeValue]
                           animated:YES
                          withBlock:^(CGRect highlightFrame) {

                              // scroll to block
                              highlightFrame.origin.y += highlightFrame.size.height;
                              [self->_noteEditorTextView scrollRectToVisible:highlightFrame
                                                      animated:YES];
                              
                              
                          }];
    }
    
    
}

- (void)endSearching:(id)sender {
    
    if ([sender isEqual:doneSearchButton])
        [[SPAppDelegate sharedDelegate].noteListViewController endSearching];
    
    _noteEditorTextView.text = [_noteEditorTextView getPlainTextContent];
    [_noteEditorTextView processChecklists];
    
    _searchString = nil;
    self.searchResultRanges = nil;
    
    [_noteEditorTextView clearHighlights:(sender ? YES : NO)];
    
    bSearching = NO;

    [self.navigationController setToolbarHidden:YES animated:YES];
    searchDetailLabel.text = nil;
}


#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // don't apply wrong transform in overscroll regions
    
    CGFloat transformAmount = scrollPosition - scrollView.contentOffset.y;
    
    BOOL disableFromTopBounce = (scrollView.contentOffset.y < -scrollView.contentInset.top && transformAmount < 0);
    BOOL disableFromBottomBounce = (scrollView.contentOffset.y > scrollView.contentInset.top + scrollView.contentSize.height && transformAmount < 0);
    BOOL disableShrinkingingWhileScrollingUp = (transformAmount > 0 && scrollView.contentOffset.y > -44);
    BOOL disableFromSmallContentSize = (scrollView.contentSize.height < (scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom));

    BOOL applyTransform = YES;
    
    // a whole mess of conditionals that affect the behavior
    if (disableFromTopBounce || disableFromBottomBounce || disableShrinkingingWhileScrollingUp ||
        bDisableShrinkingNavigationBar || disableFromSmallContentSize) {
        applyTransform = NO;
    }
    
    if (applyTransform) {
        [self applyNavigationBarTranslationTransformX:0
                                                    Y:transformAmount];
    }
        
    if (disableFromSmallContentSize && !CGAffineTransformIsIdentity(navigationBarTransform)) {
        [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
    }
    
    scrollPosition = scrollView.contentOffset.y;

    // Slowly Fade-In the NavigationBar's Blur
    [self.navigationBarBackground adjustAlphaMatchingContentOffsetOf:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    bDisableShrinkingNavigationBar = NO;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    // exand navigation bar if velocity is high enought
    if (velocity.y < -1.0) {
        [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    
    if (CGAffineTransformIsIdentity(navigationBarTransform))
        return YES;
    else {
        
        [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
        return NO;
    }
        
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    
    [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
}

- (void)navigationBarContainerTapped:(UITapGestureRecognizer *)gesture {
    
    [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
}

- (void)resetNavigationBarToIdentityWithAnimation:(BOOL)animated completion:(void (^)())completion {
    
    bDisableShrinkingNavigationBar = YES;
    
    navigationBarTransform = CGAffineTransformIdentity;
    
    void (^animationBlock)() = ^() {
        
        self.backButton.transform = CGAffineTransformIdentity;
        self.keyboardButton.transform = CGAffineTransformIdentity;
        self.createNoteButton.transform = CGAffineTransformIdentity;
        self.createNoteButton.alpha = 1.0;
        self.actionButton.transform = CGAffineTransformIdentity;
        self.actionButton.alpha = 1.0;
        self.checklistButton.transform = CGAffineTransformIdentity;
        self.checklistButton.alpha = 1.0;
        self.keyboardButton.alpha = 1.0;
        self.navigationController.navigationBar.transform = self->navigationBarTransform;
        self.navigationBarBackground.transform = CGAffineTransformIdentity;

        self.backButton.alpha = 1.0;
    };
    
    void (^completionBlock)() = ^() {
        
        if (!self->_noteEditorTextView.dragging && !self->_noteEditorTextView.decelerating) {
            self->bDisableShrinkingNavigationBar = NO;
        }
        
        if (completion)
            completion();
    };
    
    if (animated) {
        [UIView animateWithDuration:0.2
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:8.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             animationBlock();
                             
                         } completion:^(BOOL finished) {
                             
                             completionBlock();
                             
                         }];
    } else {
        
        [UIView performWithoutAnimation:^{
            
            animationBlock();
            completionBlock();
        }];
        
    }
    
}


- (void)applyNavigationBarTranslationTransformX:(float)x Y:(float)y {
    
    if ([UIDevice isPad] || self.voiceoverEnabled) {
        return;
    }
    
    CGFloat navigationBarHeight = self.navigationController.navigationBar.bounds.size.height;
    
    CGRect containerViewFrame = navigationButtonContainer.bounds;
    containerViewFrame.size.height = navigationBarHeight;
    
    BOOL isPortrait = self.isViewHorizontallyCompact && !self.isViewVerticallyCompact;
    if (isPortrait) {
        navigationBarHeight -= 20;
    }
    
    CGFloat yTransform = MAX(MIN(0, navigationBarTransform.ty + y), -navigationBarHeight);
    
    navigationBarTransform = CGAffineTransformMakeTranslation(navigationBarTransform.tx + x,
                                                              yTransform);
    
    
    // apply transform to button container
    CGFloat normalHeight = navigationButtonContainer.frame.size.height;
    CGFloat desiredHeight = normalHeight - 24;

    CGFloat percentTransform = ABS(yTransform) / 24;

    CGFloat scaleAmount = normalHeight - percentTransform * (normalHeight - desiredHeight);
    scaleAmount = scaleAmount / normalHeight;
    CGFloat alphaAmount = 1 - percentTransform;
    
    scaleAmount = MIN(1, MAX(scaleAmount, 0.8));
    
    alphaAmount = MIN(1, MAX(alphaAmount, 0.0));
    

    self.backButton.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleAmount, scaleAmount),
                                                       CGAffineTransformMakeTranslation(yTransform / 4.0, -yTransform / 2.0));
    self.backButton.alpha = isPortrait ? 1.0 : alphaAmount;
    self.keyboardButton.transform =CGAffineTransformConcat(CGAffineTransformMakeScale(scaleAmount, scaleAmount),
                                                      CGAffineTransformMakeTranslation(0, -yTransform / 2.0));
    self.keyboardButton.alpha = isPortrait ? 1.0 : alphaAmount;
    self.createNoteButton.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleAmount, scaleAmount),
                                                  CGAffineTransformMakeTranslation(0, -yTransform / 2.0));
    self.createNoteButton.alpha = alphaAmount;
    
    self.actionButton.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleAmount, scaleAmount),
                                                  CGAffineTransformMakeTranslation(0, -yTransform / 2.0));
    self.actionButton.alpha = alphaAmount;
    
    self.checklistButton.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleAmount, scaleAmount),
                                                     CGAffineTransformMakeTranslation(0, -yTransform / 2.0));
    self.checklistButton.alpha = alphaAmount;
    
    
    self.navigationController.navigationBar.transform = navigationBarTransform;
    self.navigationBarBackground.transform = CGAffineTransformConcat(CGAffineTransformIdentity,
                                                                    CGAffineTransformMakeTranslation(0, yTransform));
}

#pragma mark UITextViewDelegate methods

// only called for user changes
// safe to alter text attributes here

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if (bSearching)
        [self endSearching:textView];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
        
    BOOL appliedAutoBullets = [textView applyAutoBulletsWithReplacementText:text replacementRange:range];
    
    return !appliedAutoBullets;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    
    // Don't allow "3d press" on our checkbox images
    return interaction != UITextItemInteractionPresentActions;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    bBlankNote = NO;
    bModified = YES;
    
    [saveTimer invalidate];
    saveTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                 target:self
                                               selector:@selector(saveAndSync:)
                                               userInfo:nil
                                                repeats:NO];
    saveTimer.tolerance = 0.1;
    
    if (!guarenteedSaveTimer) {
        guarenteedSaveTimer = [NSTimer scheduledTimerWithTimeInterval:21.0
                                                               target:self
                                                             selector:@selector(saveAndSync:)
                                                             userInfo:nil
                                                              repeats:NO];
        guarenteedSaveTimer.tolerance = 1.0;
    }
    
    if([textView.text hasSuffix:@"\n"] && _noteEditorTextView.selectedRange.location == _noteEditorTextView.text.length) {
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CGPoint bottomOffset = CGPointMake(0, self->_noteEditorTextView.contentSize.height - self->_noteEditorTextView.bounds.size.height);
            if (self->_noteEditorTextView.contentOffset.y < bottomOffset.y)
                [self->_noteEditorTextView setContentOffset:bottomOffset animated:YES];
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

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    BOOL containsHttpScheme = [URL containsHttpScheme];

    // When `performsAggressiveLinkWorkaround` is true we'll get link interactions via `receivedInteractionWithURL:`
    if (containsHttpScheme && !_noteEditorTextView.performsAggressiveLinkWorkaround) {
        [self presentSafariViewControllerAtURL:URL];
    }

    return !containsHttpScheme;
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

#pragma mark Note information

- (NSInteger)wordCount {
    if (_noteEditorTextView.text == nil || [_noteEditorTextView.text length] == 0)
        return 0;
    return _noteEditorTextView.text.wordCount;
}

- (NSInteger)charCount {
    if (_noteEditorTextView.text == nil)
        return 0;
    return _noteEditorTextView.text.charCount;
}

#pragma mark Simperium

- (void)cancelSaveTimers {
    
    [saveTimer invalidate];
	saveTimer = nil;
    
    [guarenteedSaveTimer invalidate];
    guarenteedSaveTimer = nil;
}

-(void)saveAndSync:(NSTimer *)timer
{
	[self save];
    [self cancelSaveTimers];
}


- (void)save {
    
	if (_currentNote == nil || bViewingVersions || [self isDictatingText])
		return;    
    
	if (bModified || _currentNote.deleted == YES)
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
        
        bModified = NO;
	}
}

- (void)willReceiveNewContent {
    
    cursorLocationBeforeRemoteUpdate = [_noteEditorTextView selectedRange].location;
    noteContentBeforeRemoteUpdate = [_noteEditorTextView getPlainTextContent];
	
    if (_currentNote != nil && ![_noteEditorTextView.text isEqualToString:@""]) {
        _currentNote.content = [_noteEditorTextView getPlainTextContent];
        [[SPAppDelegate sharedDelegate].simperium saveWithoutSyncing];
    }
}

- (void)didReceiveNewContent {
    
	NSUInteger newLocation = [self newCursorLocation:_currentNote.content
											 oldText:noteContentBeforeRemoteUpdate
									 currentLocation:cursorLocationBeforeRemoteUpdate];
	
	_noteEditorTextView.attributedText = [_currentNote.content attributedString];
    [_noteEditorTextView processChecklists];
	
	NSRange newRange = NSMakeRange(newLocation, 0);
	[_noteEditorTextView setSelectedRange:newRange];
	
	NSArray *tags = _currentNote.tagsArray;
	if (tags.count > 0) {
		[_tagView setupWithTagNames:tags];
    }
    [self updatePublishUI];
}

- (void)didReceiveVersion:(NSString *)version data:(NSDictionary *)data {
    
    if (bViewingVersions) {
        if (noteVersionData == nil) {
            noteVersionData = [NSMutableDictionary dictionaryWithCapacity:10];
        }
        NSInteger versionInt = [version integerValue];
        [noteVersionData setObject:data forKey:[NSNumber numberWithInteger:versionInt]];
        
        [versionPickerView reloadData];
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
    
    [self endEditing:sender];
    [_tagView endEditing:YES];
}

- (void)newButtonAction:(id)sender {

    if (_currentNote && bBlankNote) {
        [_noteEditorTextView becomeFirstResponder];
        return;
    }
    
    if ([sender isEqual:self.createNoteButton]) {
        [SPTracker trackEditorNoteCreated];
    }
    
    bDisableShrinkingNavigationBar = YES; // disable the navigation bar shrinking to avoid weird animations
    
	NSManagedObjectContext *context = [[SPAppDelegate sharedDelegate] managedObjectContext];
    Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
    newNote.modificationDate = [NSDate date];
    newNote.creationDate = [NSDate date];

    // Set the note's markdown tag according to the global preference (defaults NO for new accounts)
    newNote.markdown = [[NSUserDefaults standardUserDefaults] boolForKey:kSimplenoteMarkdownDefaultKey];

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
        [self updateNote:newNote];
        bBlankNote = YES;

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

        [self updateNote:newNote];
        bBlankNote = YES;
    }
    
    bDisableShrinkingNavigationBar = NO;
}

- (void)insertChecklistAction:(id)sender {
    [_noteEditorTextView insertOrRemoveChecklist];
    
    [SPTracker trackEditorChecklistInserted];
}

- (void)actionButtonAction:(id)sender {
    
    [self save];
    
    [self endEditing:sender];
    [_tagView endEditing:YES];
    // show actions
    
	[SPTracker trackEditorActivitiesAccessed];
	

    NSArray *actionStrings,  *actionImages, *toggleTitles, *toggleSelectedTitles, *buttonStrings;

    actionStrings = @[NSLocalizedString(@"Send", @"Verb - send the content of the note by email, message, etc"),
                      NSLocalizedString(@"History...", @"Action - view the version history of a note"),
                      NSLocalizedString(@"Collaborate", @"Verb - work with others on a note"),
                      NSLocalizedString(@"Trash-verb", @"Trash (verb) - the action of deleting a note")];
    actionImages = @[[UIImage imageWithName:UIImageNameShare],
                     [UIImage imageWithName:UIImageNameHistory],
                     [UIImage imageWithName:UIImageNameCollaborate],
                     [UIImage imageWithName:UIImageNameTrash]];
    toggleTitles = @[NSLocalizedString(@"Publish", @"Verb - Publishing a note creates  URL and for any note in a user's account, making it viewable to others"),
                    NSLocalizedString(@"Pin to Top", @"Denotes when note is pinned to the top of the note list"), NSLocalizedString(@"Markdown", @"Special formatting that can be turned on for notes")];
    toggleSelectedTitles = @[NSLocalizedString(@"Published", nil),
                             NSLocalizedString(@"Pinned", @"Pinned notes are stuck to the note of the note list"),
                             NSLocalizedString(@"Markdown", @"Special formatting that can be turned on for notes")];
    
    buttonStrings = @[NSLocalizedString(@"Note not published", nil)];
    
    NSInteger wordCount = [self wordCount];
    NSInteger charCount = [self charCount];
    
    NSString *words = [NSNumberFormatter localizedStringFromNumber:@(wordCount) numberStyle:NSNumberFormatterDecimalStyle];
    NSString *characters = [NSNumberFormatter localizedStringFromNumber:@(charCount) numberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *wordFormat = wordCount == 1 ? NSLocalizedString(@"%@ Word", @"Number of words in a note") : NSLocalizedString(@"%@ Words", @"Number of words in a note");
    NSString *charFormat = charCount == 1 ? NSLocalizedString(@"%@ Character", @"Number of Characters in a note") : NSLocalizedString(@"%@ Characters", @"Number of Characters in a note");
    NSString *status = [[[NSString stringWithFormat:wordFormat, words] stringByAppendingString:@", "] stringByAppendingString:[NSString stringWithFormat:charFormat, characters]];
    
    
    noteActivityView = [SPActivityView activityViewWithToggleTitles:toggleTitles
                                               toggleSelectedTitles:toggleSelectedTitles
                                                 actionButtonImages:actionImages
                                                 actionButtonTitles:actionStrings
                                                       buttonTitles:buttonStrings
                                                             status:status
                                                           delegate:self];
    
    [noteActivityView setToggleState:_currentNote.published atIndex:0];
    [noteActivityView setToggleState:_currentNote.pinned atIndex:1];
    [noteActivityView setToggleState:_currentNote.markdown atIndex:2];
    
    // apply accessibility messages
    
    UIButton *shareButton = [noteActivityView actionButtonAtIndex:0];
    shareButton.accessibilityLabel = NSLocalizedString(@"Share note", nil);
    shareButton.accessibilityHint = NSLocalizedString(@"share-accessibility-hint", @"Accessibility hint on share button");
    
    UIButton *historyButton = [noteActivityView actionButtonAtIndex:1];
    historyButton.accessibilityLabel = NSLocalizedString(@"History", @"Noun - the version history of a note");
    historyButton.accessibilityHint = NSLocalizedString(@"history-accessibility-hint", @"Accessibility hint on button which shows the history of a note");
    historyButton.enabled = _currentNote.version.integerValue - [self minimumNoteVersion] > 1;
    
    UIButton *collaborateButton = [noteActivityView actionButtonAtIndex:2];
    collaborateButton.accessibilityHint = NSLocalizedString(@"collaborate-accessibility-hint", @"Accessibility hint on button which shows the current collaborators on a note");
    
    UIButton *deleteButton = [noteActivityView actionButtonAtIndex:3];
    deleteButton.accessibilityLabel = NSLocalizedString(@"Trash-verb", @"Trash (verb) - the action of deleting a note");
    deleteButton.accessibilityHint = NSLocalizedString(@"trash-accessibility-hint", @"Accessibility hint on button which moves a note to the trash");

    UIButton *publishToggle = [noteActivityView toggleAtIndex:0];
    publishToggle.accessibilityLabel = NSLocalizedString(@"Publish toggle", @"Switch which marks a note as published or unpublished");
    publishToggle.accessibilityHint = _currentNote.published ? NSLocalizedString(@"Unpublish note", @"Action which unpublishes a note") : NSLocalizedString(@"Publish note", @"Action which published a note to a web page");

    UIButton *pinToggle = [noteActivityView toggleAtIndex:1];
    pinToggle.accessibilityLabel = NSLocalizedString(@"Pin toggle", @"Switch which marks a note as pinned or unpinned");
    pinToggle.accessibilityHint = _currentNote.pinned ? NSLocalizedString(@"Unpin note", @"Action to mark a note as unpinned") : NSLocalizedString(@"Pin note", @"Action to mark a note as pinned");

    UIButton *markdownToggle = [noteActivityView toggleAtIndex:2];
    markdownToggle.accessibilityLabel = NSLocalizedString(@"Markdown toggle", @"Switch which marks a note as using Markdown formatting or not");
    markdownToggle.accessibilityHint = _currentNote.markdown ? NSLocalizedString(@"Disable Markdown formatting", nil) : NSLocalizedString(@"Enable Markdown formatting", nil);

    UIButton *publishURLButton = [noteActivityView buttonAtIndex:0];
    [publishURLButton setTitle:buttonStrings[0] forState:UIControlStateDisabled];
    [self updatePublishUI];

    
    if ([UIDevice isPad] && !self.isViewHorizontallyCompact) {
        // widen noteActivityView to show all content in the popover
        CGRect activityViewFrame = noteActivityView.frame;
        activityViewFrame.size.width = [self.theme floatForKey:@"actionViewWidth"];
        noteActivityView.frame = activityViewFrame;

        SPPopoverContainerViewController *popoverVC = [[SPPopoverContainerViewController alloc] initWithCustomView:noteActivityView];
        popoverVC.modalPresentationStyle = UIModalPresentationPopover;
        popoverVC.popoverPresentationController.sourceView = sender;
        popoverVC.popoverPresentationController.sourceRect = ((UIView *)sender).bounds;
        popoverVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popoverVC.popoverPresentationController.delegate = self;

        UIColor *actionSheetColor = [[UIColor simplenoteBackgroundColor] colorWithAlphaComponent:0.97];
        popoverVC.popoverPresentationController.backgroundColor = actionSheetColor;

        [self presentViewController:popoverVC animated:YES completion:nil];
    } else {
        noteActionSheet = [SPActionSheet showActionSheetInView:self.navigationController.view
                                                   withMessage:nil
                                          withContentViewArray:@[noteActivityView]
                                          withButtonTitleArray:@[NSLocalizedString(@"Done", nil)]
                                                      delegate:self ];
        noteActionSheet.swipeToDismiss = YES;
    }
}

- (void)dismissActivityView {
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    // ActionSheet Scenario
    [noteActionSheet dismiss];
    noteActionSheet = nil;
}

- (void)activityView:(SPActivityView *)activityView didToggleIndex:(NSInteger)index enabled:(BOOL)enabled {
    
    bModified = YES;

    switch (index) {
        case 0: // Publish Note
        {
            if (enabled) {
                [self publishNote:^(BOOL success) {
                    [activityView setToggleState:success atIndex:index];
                }];

            } else  {
                [self unpublishNote:nil];
            }

            UIButton *publishToggle = [noteActivityView toggleAtIndex:0];
            publishToggle.accessibilityHint = _currentNote.published ? NSLocalizedString(@"Unpublish note", nil) : NSLocalizedString(@"Publish note", nil);
            break;
        }
        case 1: // Pin Note
        {
            _currentNote.pinned = enabled;

            [self save];

            UIButton *pinToggle = [noteActivityView toggleAtIndex:1];
            pinToggle.accessibilityHint = _currentNote.pinned ? NSLocalizedString(@"Unpin note", nil) : NSLocalizedString(@"Pin note", nil);
            break;
        }
        case 2: // Toggle Markdown
        {
            _currentNote.markdown = enabled;

            [self save];

            // If Markdown is being enabled and it was previously disabled
            bounceMarkdownPreviewOnActivityViewDismiss = (enabled && ![[NSUserDefaults standardUserDefaults] boolForKey:kSimplenoteMarkdownDefaultKey]);

            // Update the global preference to use when creating new notes
            [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSimplenoteMarkdownDefaultKey];

            // Track analytics
            if (enabled) {
                [SPTracker trackEditorNoteMarkdownEnabled];
            } else {
                [SPTracker trackEditorNoteMarkdownDisabled];
            }

            UIButton *markdownToggle = [noteActivityView toggleAtIndex:2];
            markdownToggle.accessibilityHint = _currentNote.markdown ? NSLocalizedString(@"Disable Markdown formatting", nil) : NSLocalizedString(@"Enable Markdown formatting", nil);
            break;
        }
        default: break;
    }
}

- (void)updatePublishUI {
    UIButton *publishToggle = [noteActivityView toggleAtIndex:0];
    UIButton *urlButton = [noteActivityView buttonAtIndex:0];
    if (_currentNote.published && _currentNote.publishURL.length == 0) {
        [noteActivityView showActivityIndicator];
        [urlButton setTitle:NSLocalizedString(@"Publishing...", @"Message shown when a note is in the processes of being published")
                   forState:UIControlStateNormal];
        urlButton.enabled = YES;
        publishToggle.enabled = NO;
    } else if (_currentNote.published && _currentNote.publishURL.length > 0) {
        [noteActivityView hideActivityIndicator];
        [urlButton setTitle:[NSString stringWithFormat:@"%@%@", kSimplenotePublishURL, _currentNote.publishURL]
                   forState:UIControlStateNormal];
        urlButton.enabled = YES;
        publishToggle.enabled = YES;
    } else if (!_currentNote.published && _currentNote.publishURL.length == 0) {
        [noteActivityView hideActivityIndicator];
        urlButton.enabled = NO;
        publishToggle.enabled = YES;
    } else if (!_currentNote.published && _currentNote.publishURL.length > 0) {
        [noteActivityView showActivityIndicator];
        [urlButton setTitle:NSLocalizedString(@"Unpublishing...", @"Message shown when a note is in the processes of being unpublished")
                   forState:UIControlStateNormal];
        urlButton.enabled = YES;
        publishToggle.enabled = NO;
    }
}

- (void)activityView:(SPActivityView *)activityView didSelectActionAtIndex:(NSInteger)index {
    
    [self dismissActivityView];

    switch (index) {
        case 0: {
            [self shareNoteContentAction:activityView];
            return;
            break;
        } case 1: {
            [self viewVersionAction:activityView];
            break;
        } case 2: {
            [self addCollaboratorsAction:activityView];
            break;
        } case 3: {
            [SPTracker trackEditorNoteDeleted];
            [self trashNoteAction:activityView];
            break;
        }
            
        default:
            break;
    }
    
}

- (void)activityView:(SPActivityView *)activityView didSelectButtonAtIndex:(NSInteger)index {
    
    [self dismissActivityView];

        if (index == 0)
            [self shareNoteURLAction:nil];
}

- (void)actionSheet:(SPActionSheet *)actionSheet didSelectItemAtIndex:(NSInteger)index {

    if ([actionSheet isEqual:versionActionSheet]) {
        
        bViewingVersions = NO;
        
        if (index == 0) {
            
            // revert back to current version
            _noteEditorTextView.attributedText = [_currentNote.content attributedString];
        } else {
            
            [SPTracker trackEditorNoteRestored];
            
            bModified = YES;
            [self save];
        }
        
        [_noteEditorTextView processChecklists];
        // Unload versions and re-enable editor
        [_noteEditorTextView setEditable:YES];
        noteVersionData = nil;
        [(SPNavigationController *)self.navigationController setDisableRotation:NO];
    }
    
    [actionSheet dismiss];
}

- (void)actionSheetDidShow:(SPActionSheet *)actionSheet {
    
    bActionSheetVisible = YES;
}

- (void)actionSheetDidDismiss:(SPActionSheet *)actionSheet {
    
    bActionSheetVisible = NO;
    
    if ([actionSheet isEqual:noteActionSheet])
        noteActionSheet = nil;
    
    if ([actionSheet isEqual:versionActionSheet])
        versionActionSheet = nil;

    if (bounceMarkdownPreviewOnActivityViewDismiss) {
        [self bounceMarkdownPreview];
    }
}


#pragma mark Note Actions

- (CGRect)presentationRectForActionButton {
    
    return [self.view convertRect:self.actionButton.frame
                         fromView:self.actionButton.superview];
    
}

- (void)publishNote:(void(^)(BOOL success))completion {
    
    [SPTracker trackEditorNotePublished];

    _currentNote.published = YES;
    [self save];
    [self updatePublishUI];

    if (completion) {
        completion(YES);
    }
}

- (void)unpublishNote:(void(^)(BOOL success))completion {

    [SPTracker trackEditorNoteUnpublished];

    _currentNote.published = NO;
    [self save];
    [self updatePublishUI];

    if (completion) {
        completion(YES);
    }
}

- (void)shareNoteContentAction:(id)sender {
    
    if (_currentNote.content == nil) {
        return;
    }
    
    [self save];
    
    [SPTracker trackEditorNoteContentShared];

    UIActivityViewController *acv = [[UIActivityViewController alloc] initWithNote:_currentNote];

    if ([UIDevice isPad]) {
        acv.modalPresentationStyle = UIModalPresentationPopover;
        acv.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        acv.popoverPresentationController.sourceRect = [self presentationRectForActionButton];
        acv.popoverPresentationController.sourceView = self.view;
    }

    [self presentViewController:acv animated:YES completion:nil];
}

- (void)shareNoteURLAction:(id)sender {
    
    
    if (!_currentNote.published) {
        return;
	}
    
	[SPTracker trackEditorPublishedUrlPressed];
    
    NSURL *publishURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kSimplenotePublishURL, _currentNote.publishURL]];
    
    SPAcitivitySafari *safariActivity = [[SPAcitivitySafari alloc] init];
    
    UIActivityViewController *acv = [[UIActivityViewController alloc] initWithActivityItems:@[publishURL]
                                                                      applicationActivities:@[safariActivity]];

    if ([UIDevice isPad]) {
        acv.modalPresentationStyle = UIModalPresentationPopover;
        acv.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        acv.popoverPresentationController.sourceRect = [self presentationRectForActionButton];
        acv.popoverPresentationController.sourceView = self.view;
        [self presentViewController:acv animated:YES completion:nil];
    } else {
        [self.navigationController presentViewController:acv animated:YES completion:nil];
    }
}


- (void)showNoteActivityViewController {
    
    if (!_currentNote.published || !(_currentNote.publishURL.length > 0))
        return;
    
    NSURL *publishURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kSimplenotePublishURL, _currentNote.publishURL]];

    
    UIActivityViewController *acv = [[UIActivityViewController alloc] initWithActivityItems:@[publishURL]
                                                                      applicationActivities:nil];
    
    [self.navigationController presentViewController:acv
                                            animated:YES
                                          completion:nil];
    
}


- (void)addCollaboratorsAction:(id)sender {
    
    [SPTracker trackEditorCollaboratorsAccessed];
	   
    SPAddCollaboratorsViewController *vc = [[SPAddCollaboratorsViewController alloc] init];
    vc.collaboratorDelegate = self;
    [vc setupWithCollaborators:_currentNote.emailTagsArray];

    SPNavigationController *navController = [[SPNavigationController alloc] initWithRootViewController:vc];
    navController.displaysBlurEffect = YES;
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
    
}

-(void)togglePinStatusAction:(id)sender
{
	_currentNote.pinned = !_currentNote.pinned;
	bModified = YES;
    
    if (_currentNote.pinned) {
        [SPTracker trackEditorNotePinned];
    } else {
        [SPTracker trackEditorNoteUnpinned];
    }
    
    [self save];
}

- (void)viewVersionAction:(id)sender {
    
    // check reachability status
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
    bViewingVersions = YES;
    currentVersion = 0; // reset the version number
    
    [_noteEditorTextView setEditable:NO];
    
    // Request the version data from Simperium
    [[[SPAppDelegate sharedDelegate].simperium bucketForName:@"Note"] requestVersions:30 key:_currentNote.simperiumKey];
    
    
    versionPickerView = [[SPHorizontalPickerView alloc] initWithFrame:CGRectMake(0,
                                                                                 0,
                                                                                 self.view.frame.size.width,
                                                                                 200) itemClass:[SPVersionPickerViewCell class]
                                                             delegate:self];
    
    [versionPickerView setSelectedIndex:[NSNumber numberWithInteger:(_currentNote.version.integerValue - [self minimumNoteVersion] - 1)].integerValue];
    
    versionActionSheet = [SPActionSheet showActionSheetInView:self.navigationController.view
                                                  withMessage:nil
                                         withContentViewArray:@[versionPickerView]
                                         withButtonTitleArray:@[NSLocalizedString(@"Cancel", nil), NSLocalizedString(@"Restore Note", @"Restore a note to a previous version")]
                                                     delegate:self];
    versionActionSheet.tapToDismiss = NO;
    versionActionSheet.cancelButtonIndex = 0;

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

- (void)trashNoteAction:(id)sender {

    // create a snapshot before the animation
    UIView *snapshot = [_noteEditorTextView snapshotViewAfterScreenUpdates:NO];
    snapshot.frame = _noteEditorTextView.frame;
    [self.view addSubview:snapshot];
    
    [[SPObjectManager sharedManager] trashNote:_currentNote];
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableNote:_currentNote];
    
    [self clearNote];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         snapshot.transform = CGAffineTransformMakeTranslation(0, -snapshot.frame.size.height);
                         snapshot.alpha = 0.0;
                         
                     } completion:^(BOOL finished) {
                         
                         [snapshot removeFromSuperview];
                         [self backButtonAction:nil];
                         
                     }];
}

#pragma mark SPHorizontalPickerView delegate methods

- (NSInteger)numberOfItemsInPickerView:(SPHorizontalPickerView *)pickerView {
    
    NSLog(@"there are %ld versions", _currentNote.version.integerValue - [self minimumNoteVersion]);
    
    return _currentNote.version.integerValue - [self minimumNoteVersion];
}

- (SPHorizontalPickerViewCell *)pickerView:(SPHorizontalPickerView *)pickerView viewForIndex:(NSInteger)index {
    
    SPVersionPickerViewCell *cell = (SPVersionPickerViewCell *)[pickerView dequeueReusableCellforIndex:index];
    
    NSInteger versionInt = index + [self minimumNoteVersion] + 1;
    NSDictionary *versionData = [noteVersionData objectForKey:[NSNumber numberWithInteger:versionInt]];
    
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
    if (versionInt == currentVersion)
        return;
    
    currentVersion = versionInt;
	NSDictionary *versionData = [noteVersionData objectForKey:[NSNumber numberWithInteger:versionInt]];
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


#pragma mark SPCollaboratorDelegate methods 

- (BOOL)collaboratorViewController:(SPAddCollaboratorsViewController *)viewController
             shouldAddCollaborator:(NSString *)collaboratorName {
    
    return ![_currentNote hasTag:collaboratorName];
    
}

- (void)collaboratorViewController:(SPAddCollaboratorsViewController *)viewController
                didAddCollaborator:(NSString *)collaboratorName {

    [_currentNote addTag:collaboratorName];
    bBlankNote = NO;
    bModified = YES;
    [self save];
    
    [SPTracker trackEditorEmailTagAdded];
}

- (void)collaboratorViewController:(SPAddCollaboratorsViewController *)viewController
             didRemoveCollaborator:(NSString *)collaboratorName {
    
    [_currentNote stripTag:collaboratorName];
    bBlankNote = NO;
    bModified = YES;
    [self save];

    [SPTracker trackEditorEmailTagRemoved];
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
    bBlankNote = NO;
    bModified = YES;
    [self save];
    
    [SPTracker trackEditorTagAdded];
}

- (BOOL)tagView:(SPTagView *)tagView shouldCreateTagName:(NSString *)tagName {
    
    return ![_currentNote hasTag:tagName];
}

- (void)tagView:(SPTagView *)tagView didRemoveTagName:(NSString *)tagName {
    
    [_currentNote stripTag:tagName];
    bBlankNote = NO;
    bModified = YES;
    
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
