//
//  SPNoteEditorViewController.m
//  Simplenote
//
//  Created by Tom Witkin on 7/9/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPNoteEditorViewController.h"
#import "Note.h"
#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"
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
#import "UIView+ImageRepresentation.h"
#import "UITextView+Simplenote.h"
#import "SPObjectManager.h"
#import "SPInteractiveTextStorage.h"
#import "SPTracker.h"
#import "NSString+Bullets.h"
#import "SPTransitionController.h"
#import "UIImage+Extensions.h"
#import "NSString+Search.h"
#import "SPTextView.h"
#import "NSString+Attributed.h"
#import "SPAcitivitySafari.h"
#import "SPNavigationController.h"
#import "SPMarkdownPreviewViewController.h"
#import "SPTextLinkifier.h"
#import "UIDevice+Extensions.h"
#import "UIViewController+Extensions.h"
#import "SPInteractivePushPopAnimationController.h"
#import "Simplenote-Swift.h"
#import "SPConstants.h"

@import SafariServices;

NSString * const kWillAddNewNote = @"SPWillAddNewNote";

CGFloat const SPCustomTitleViewHeight            = 44.0f;
CGFloat const SPPaddingiPadCompactWidthPortrait  =  8.0f;
CGFloat const SPPaddingiPadLeading               =  4.0f;
CGFloat const SPPaddingiPadTrailing              = -2.0f;
CGFloat const SPPaddingiPhoneLeadingLandscape    =  0.0f;
CGFloat const SPPaddingiPhoneLeadingPortrait     =  8.0f;
CGFloat const SPPaddingiPhoneTrailingLandscape   = 14.0f;
CGFloat const SPPaddingiPhoneTrailingPortrait    =  6.0f;
CGFloat const SPBarButtonYOriginAdjustment       = -1.0f;
CGFloat const SPMultitaskingCompactOneThirdWidth = 320.0f;


@interface SPNoteEditorViewController ()<SPInteractivePushViewControllerProvider, UIPopoverPresentationControllerDelegate> {
    NSUInteger cursorLocationBeforeRemoteUpdate;
    NSString *noteContentBeforeRemoteUpdate;
    BOOL bounceMarkdownPreviewOnActivityViewDismiss;
}

@property (nonatomic, strong) SPTextLinkifier           *textLinkifier;
@property (nonatomic, strong) UIFont                    *bodyFont;
@property (nonatomic, strong) NSMutableParagraphStyle   *paragraphStyle;
@property (nonatomic, strong) UIFont                    *headlineFont;
@property (nonatomic, strong) UIColor                   *fontColor;
@property (nonatomic, strong) UIColor                   *lightFontColor;
@property (nonatomic, assign) CGFloat                   keyboardHeight;

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
        _noteEditorTextView = [[SPEditorTextView alloc] init];
        
        // Data Detectors:
        // Disabled by default. This will be entirely handled by SPTextLinkifier
        _noteEditorTextView.dataDetectorTypes = UIDataDetectorTypeNone;
        
        // TagView
        _tagView = _noteEditorTextView.tagView;
        _noteEditorTextView.tagView.tagDelegate = self;
        
        // Linkifier
        _textLinkifier = [SPTextLinkifier linkifierWithTextView:_noteEditorTextView];
        
        // Helpers
        scrollPosition = _noteEditorTextView.contentOffset.y;
        navigationBarTransform = CGAffineTransformIdentity;
        
        bDisableShrinkingNavigationBar = NO;
        bShouldDelete = NO;
        _keyboardHeight = 0;
        
        // Notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backButtonAction:)
                                                     name:SPTransitionControllerPopGestureTriggeredNotificationName
                                                   object:nil];
        
        
        // voiceover status is tracked because the tag view is anchored
        // to the bottom of the screen when voiceover is enabled to allow
        // easier access
        bVoiceoverEnabled = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveVoiceOverNotification:)
                                                     name:UIAccessibilityVoiceOverStatusChanged
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    
    return self;
}

- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

- (void)applyStyle {
    
    _bodyFont = [self.theme fontWithSystemSizeForKey:@"noteBodyFont"];
    _headlineFont = [self.theme fontWithSystemSizeForKey:@"noteHeadlineFont"];
    _fontColor = [self.theme colorForKey:@"noteHeadlineFontColor"];
    _lightFontColor = [self.theme colorForKey:@"noteBodyFontPreviewColor"];
    
    _noteEditorTextView.font = _bodyFont;
    _tagView = _noteEditorTextView.tagView;
    [_tagView applyStyle];
    
    _paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    _paragraphStyle.lineSpacing = _bodyFont.lineHeight * [self.theme floatForKey:@"noteBodyLineHeightPercentage"];
    
    _noteEditorTextView.interactiveTextStorage.tokens = @{SPDefaultTokenName : @{ NSForegroundColorAttributeName : _fontColor, NSFontAttributeName : _bodyFont, NSParagraphStyleAttributeName : _paragraphStyle, NSStrokeWidthAttributeName:[NSNumber numberWithFloat:[self.theme floatForKey:@"noteBodyStrokeWidth"]] }, SPHeadlineTokenName : @{NSForegroundColorAttributeName: _fontColor, NSFontAttributeName : _headlineFont, NSStrokeWidthAttributeName:[NSNumber numberWithFloat:[self.theme floatForKey:@"noteHeadlineStrokeWidth"]]} };
    
    _noteEditorTextView.backgroundColor = [self.theme colorForKey:@"backgroundColor"];
    
    _noteEditorTextView.keyboardAppearance = (self.theme.isDark ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat tagViewHeight = [self.theme floatForKey:@"tagViewHeight"];
    _tagView.frame = CGRectMake(0,
                                self.view.frame.size.height - tagViewHeight,
                                self.view.frame.size.width,
                                tagViewHeight);

    [self.view addSubview:_noteEditorTextView];
    _noteEditorTextView.frame = self.view.bounds;
    _noteEditorTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _noteEditorTextView.delegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationItem.title = nil;
    
    [self startListeningToNotifications];
    [self applyStyle];
    [self setupBarItems];
    [self swapTagViewPositionForVoiceover];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self resetNavigationBarToIdentityWithAnimation:NO completion:nil];
    [self.navigationController setToolbarHidden:!bSearching animated:YES];

    [self sizeNavigationContainer];
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (!_currentNote)
        [self newButtonAction:nil];
    
    if (!(_noteEditorTextView.text.length > 0) && !bActionSheetVisible)
        [_noteEditorTextView becomeFirstResponder];

    if (_tagView.alpha < 1.0) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.tagView.alpha = 1.0;
                         }];
    }
    
    [self highlightSearchResultsIfNeeded];
}

- (void)startListeningToNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [nc addObserver:self selector:@selector(themeDidChange) name:VSThemeManagerThemeDidChangeNotification object:nil];
}

- (void)themeDidChange {
    [self applyStyle];
}

- (void)highlightSearchResultsIfNeeded
{
    if (!bSearching || _searchString.length == 0 || searchResultRanges) {
        return;
    }
    
    self.textLinkifier.enabled = NO;
    NSString *searchText = _noteEditorTextView.text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        searchResultRanges = [searchText rangesForTerms:_searchString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIColor *tintColor = [self.theme colorForKey:@"tintColor"];
            [_noteEditorTextView.textStorage applyColorAttribute:tintColor forRanges:searchResultRanges];
            
            NSInteger count = searchResultRanges.count;
            
            NSString *searchDetailFormat = count == 1 ? NSLocalizedString(@"%d Result", @"Number of found search results") : NSLocalizedString(@"%d Results", @"Number of found search results");
            searchDetailLabel.text = [NSString stringWithFormat:searchDetailFormat, count];
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 
                                 searchDetailLabel.alpha = 1.0;
                             }];
            
            highlightedSearchResultIndex = 0;
            [self highlightSearchResultAtIndex:highlightedSearchResultIndex];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self refreshNavBarSizeWithCoordinator:coordinator];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self refreshNavBarSizeWithCoordinator:coordinator];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self dismissActivityView];
}

- (void)refreshNavBarSizeWithCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        bDisableShrinkingNavigationBar = YES;
        [self sizeNavigationContainer];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        bDisableShrinkingNavigationBar = NO;
    }];
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
    
    backButton.frame = CGRectMake(leadingPadding,
                                  SPBarButtonYOriginAdjustment,
                                  backButton.frame.size.width,
                                  navigationButtonContainer.frame.size.height);
    
    CGFloat previousXOrigin = navigationButtonContainer.frame.size.width + trailingPadding;
    CGFloat buttonWidth = [self.theme floatForKey:@"barButtonWidth"];
    CGFloat buttonHeight = buttonWidth;
    
    keyboardButton.frame = CGRectMake(previousXOrigin - buttonWidth,
                                      SPBarButtonYOriginAdjustment,
                                      buttonWidth,
                                      buttonHeight);
    
    CGFloat newButtonImageWidth = [newButton imageForState:UIControlStateNormal].size.width;
    CGFloat newButtonPadding = isPad ? (buttonWidth - newButtonImageWidth) : buttonWidth;
    
    newButton.frame = CGRectMake(previousXOrigin - newButtonPadding,
                                 SPBarButtonYOriginAdjustment,
                                 buttonWidth,
                                 buttonHeight);
    
    previousXOrigin = newButton.frame.origin.x;
    
    actionButton.frame = CGRectMake(previousXOrigin - buttonWidth,
                                    SPBarButtonYOriginAdjustment,
                                    buttonWidth,
                                    buttonHeight);
}


- (void)setupBarItems {
    
    // setup Navigation Bar
    self.navigationItem.hidesBackButton = YES;
    
    // container view
    SPOutsideTouchView *titleView =[[SPOutsideTouchView alloc] init];
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
    backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:NSLocalizedString(@"Notes", @"Plural form of notes")
                forState:UIControlStateNormal];
    [backButton setImage:[[UIImage imageNamed:@"back_chevron"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                forState:UIControlStateNormal];
    backButton.titleLabel.font = [self.theme fontForKey:@"barButtonFont"];
    backButton.titleEdgeInsets = UIEdgeInsetsMake(2, -4, 0, 0);
    [backButton sizeToFit];
    backButton.autoresizingMask =  UIViewAutoresizingFlexibleHeight;
    backButton.accessibilityLabel = NSLocalizedString(@"Notes", nil);
    backButton.accessibilityHint = NSLocalizedString(@"notes-accessibility-hint", @"VoiceOver accessibiliity hint on the button that closes the notes editor and navigates back to the note list");
    
    [backButton addTarget:self
                   action:@selector(backButtonAction:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [navigationButtonContainer addSubview:backButton];
    
    
    // setup right buttons
    actionButton = [UIButton buttonWithImage:[UIImage imageNamed:@"button_action"]
                                      target:self
                                    selector:@selector(actionButtonAction:)];
    actionButton.accessibilityLabel = NSLocalizedString(@"Menu", @"Terminoligy used for sidebar UI element where tags are displayed");
    actionButton.accessibilityHint = NSLocalizedString(@"menu-accessibility-hint", @"VoiceOver accessibiliity hint on button which shows or hides the menu");
    
    newButton = [UIButton buttonWithImage:[UIImage imageNamed:@"button_new"]
                                   target:self
                                 selector:@selector(newButtonAction:)];
    newButton.accessibilityLabel = NSLocalizedString(@"New note", @"Label to create a new note");
    newButton.accessibilityHint = NSLocalizedString(@"Create a new note", nil);
    
    keyboardButton = [UIButton buttonWithImage:[UIImage imageNamed:@"button_keyboard"]
                                        target:self
                                      selector:@selector(keyboardButtonAction:)];
    keyboardButton.accessibilityLabel = NSLocalizedString(@"Dismiss keyboard", nil);

    
    keyboardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    newButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    actionButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    
    [navigationButtonContainer addSubview:keyboardButton];
    [navigationButtonContainer addSubview:newButton];
    [navigationButtonContainer addSubview:actionButton];
    
    [self setVisibleRightBarButtonsForEditingMode:NO];
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
    UIImage *chevronImage = [UIImage imageNamed:@"back_chevron"];
    nextSearchButton = [UIBarButtonItem barButtonWithImage:[chevronImage imageRotatedByDegrees:180.0]
                                            imageAlignment:UIBarButtonImageAlignmentRight
                                                    target:self
                                                  selector:@selector(highlightNextSearchResult:)];
        nextSearchButton.width = 34.0;
    prevSearchButton = [UIBarButtonItem barButtonWithImage:chevronImage
                                            imageAlignment:UIBarButtonImageAlignmentRight
                                                    target:self
                                                  selector:@selector(highlightPrevSearchResult:)];
    prevSearchButton.width = 34.0;
    
    
    searchDetailLabel = [[UILabel alloc] init];
    searchDetailLabel.font = [self.theme fontForKey:@"barButtonFont"];
    searchDetailLabel.frame = CGRectMake(0, 0, 180, searchDetailLabel.font.lineHeight);
    searchDetailLabel.textColor = [self.theme colorForKey:@"noteHeadlineFontColor"];
    searchDetailLabel.textAlignment = NSTextAlignmentCenter;
    searchDetailLabel.alpha = 0.0;
    UIBarButtonItem *detailButton = [[UIBarButtonItem alloc] initWithCustomView:searchDetailLabel];
    
    
    
    [self setToolbarItems:@[doneSearchButton, flexibleSpace, detailButton, flexibleSpaceTwo, prevSearchButton, nextSearchButton] animated:NO];
    
}

- (void)didReceiveVoiceOverNotification:(NSNotification *)notification {
    
    [self swapTagViewPositionForVoiceover];
    bVoiceoverEnabled = UIAccessibilityIsVoiceOverRunning();
    
    if (bVoiceoverEnabled)
        [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
}

- (void)swapTagViewPositionForVoiceover {
    
    if (bVoiceoverEnabled != UIAccessibilityIsVoiceOverRunning()) {
        
        CGRect viewFrame = self.view.bounds;

        if (UIAccessibilityIsVoiceOverRunning()) {
            
            [_tagView removeFromSuperview];
            CGFloat tagViewHeight = [self.theme floatForKey:@"tagViewHeight"];
            _tagView.frame = CGRectMake(0,
                                        viewFrame.size.height - tagViewHeight - _keyboardHeight,
                                        viewFrame.size.width,
                                        tagViewHeight);
            _noteEditorTextView.tagView = nil;
            _noteEditorTextView.frame = CGRectMake(0,
                                                   0,
                                                   viewFrame.size.width,
                                                   _tagView.frame.origin.y);
            
            [self.view addSubview:_tagView];
            
        } else {
            
            _noteEditorTextView.tagView = _tagView;
            [_noteEditorTextView addSubview:_tagView];
            _noteEditorTextView.frame = CGRectMake(0,
                                                   0,
                                                   viewFrame.size.width,
                                                   viewFrame.size.height -_keyboardHeight);;
            [_noteEditorTextView setNeedsLayout];
        }
        
    }
    
}

- (void)setVisibleRightBarButtonsForEditingMode:(BOOL)editing {
    
    if ([UIDevice isPad]) {
        keyboardButton.hidden = YES;
        newButton.hidden = NO;
    } else {
        keyboardButton.hidden = !editing;
        newButton.hidden = editing;
    }
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
        
        NSIndexPath *notePath = [listController.fetchedResultsController indexPathForObject:_currentNote];
        
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
    
    [[self.navigationController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
      
        // clear the current note after pop animation completes
        [self clearNote];
        
    }];
    
}

- (void)updateNote:(Note *)note {
    
    if (!note) {
        _noteEditorTextView.text = nil;
        return;
    }
    
    _currentNote = note;
    
    // push off updating note text in order to speed up animated transition
    dispatch_async(dispatch_get_main_queue(), ^{
        _noteEditorTextView.attributedText = [note.content attributedString];
        _noteEditorTextView.contentOffset = CGPointMake(0, -_noteEditorTextView.contentInset.top);
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
    
    // hide the tags field
    if (!bVoiceoverEnabled) {
        self.tagView.alpha = 0.0;
    }
}

- (void)clearNote {
    
    bBlankNote = NO;
    _currentNote = nil;
    _noteEditorTextView.text = @"";
    
    [self endSearching:nil];
    
    [_tagView clearAllTags];
}


- (void)endEditing:(id)sender {
    
    [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
    [_tagView endEditing:YES];
    [_noteEditorTextView endEditing:YES];
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

                    bounceMarkdownPreviewOnActivityViewDismiss = NO;
                }];
            }];
        }];
    }];
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
    previewViewController.markdownText = self.noteEditorTextView.text;
    
    return previewViewController;
}

- (BOOL)interactivePushPopAnimationControllerShouldBeginPush:(SPInteractivePushPopAnimationController *)controller
{
    return self.currentNote.markdown;
}

- (void)interactivePushPopAnimationControllerWillBeginPush:(SPInteractivePushPopAnimationController *)controller
{
    // This dispatch is to prevent the animations executed when ending editing
    // from happening interactively along with the push on iOS 9.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tagView endEditing:YES];
        [self.noteEditorTextView endEditing:YES];
        
        [self resetNavigationBarToIdentityWithAnimation:YES completion:^{
            bDisableShrinkingNavigationBar = YES;
        }];
    });
}

#pragma mark search

- (void)setSearchString:(NSString *)string {
    
    if (string.length > 0) {
        bSearching = YES;
        self.textLinkifier.enabled = NO;
        _searchString = string;
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

- (void)highlightNextSearchResult:(id)sender {
    
    highlightedSearchResultIndex = MIN(highlightedSearchResultIndex + 1, searchResultRanges.count);
    [self highlightSearchResultAtIndex:highlightedSearchResultIndex];
}

- (void)highlightPrevSearchResult:(id)sender {
    
    highlightedSearchResultIndex = MAX(0, highlightedSearchResultIndex - 1);
    [self highlightSearchResultAtIndex:highlightedSearchResultIndex];
    
}

- (void)highlightSearchResultAtIndex:(NSInteger)index {
    
    NSInteger searchResultCount = searchResultRanges.count;
    if (index >= 0 && index < searchResultCount) {
        
        // enable or disbale search result puttons accordingly
        prevSearchButton.enabled = index > 0;
        nextSearchButton.enabled = index < searchResultCount - 1;
        
        [_noteEditorTextView highlightRange:[(NSValue *)searchResultRanges[index] rangeValue]
                           animated:YES
                          withBlock:^(CGRect highlightFrame) {

                              // scroll to block
                              highlightFrame.origin.y += highlightFrame.size.height;
                              [_noteEditorTextView scrollRectToVisible:highlightFrame
                                                      animated:YES];
                              
                              
                          }];
    }
    
    
}

- (void)endSearching:(id)sender {
    
    if ([sender isEqual:doneSearchButton])
        [[SPAppDelegate sharedDelegate].noteListViewController endSearching];
    
    self.textLinkifier.enabled = YES;
    _noteEditorTextView.attributedText = [_noteEditorTextView.text attributedString];
    
    _searchString = nil;
    searchResultRanges = nil;
    
    [_noteEditorTextView clearHighlights:(sender ? YES : NO)];
    
    bSearching = NO;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.navigationController.toolbar.transform = CGAffineTransformMakeTranslation(0, self.navigationController.toolbar.frame.size.height);
                     } completion:^(BOOL finished) {
                         [self.navigationController setToolbarHidden:YES animated:NO];
                         self.navigationController.toolbar.transform = CGAffineTransformIdentity;
                         searchDetailLabel.alpha = 0.0;
                         searchDetailLabel.text = nil;

                     }];
    
}


#pragma mark Keyboard Notifications

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo  = notification.userInfo;
    NSTimeInterval duration = [((NSNumber *)userInfo[UIKeyboardAnimationDurationUserInfoKey]) floatValue];
    CGRect keyboardFrame    = [((NSValue *)userInfo[UIKeyboardFrameEndUserInfoKey]) CGRectValue];
    CGSize viewBounds       = self.view.bounds.size;

    CGFloat visibleHeight   = MAX(viewBounds.height - CGRectGetMinY(keyboardFrame), 0);
    BOOL isEditing          = visibleHeight > 0;
    
    void (^animations)() = ^void() {
        CGRect newFrame            = _noteEditorTextView.frame;
        newFrame.size.height       = self.view.frame.size.height - (bVoiceoverEnabled ? _tagView.frame.size.height : 0) - visibleHeight;
        _noteEditorTextView.frame  = newFrame;
        
        if (bVoiceoverEnabled) {
            CGRect newFrame        = _tagView.frame;
            newFrame.origin.y      = self.view.frame.size.height - _tagView.frame.size.height - visibleHeight;
            _tagView.frame         = newFrame;
        }
    };
    
    // On iOS 9 the keyboard's animation doesn't happen interactively. If an interactive transition is
    // taking place, the editor text view's frame must be changed instantaneously, otherwise on
    // dismissal you can see the bottom of the text being clipped once the keyboard has dismissed.
    if (self.transitionCoordinator.isInteractive) {
        [UIView performWithoutAnimation:^{
           animations();
        }];
    } else {
        // Animate Editor Resize / Tag Reposition
        [UIView animateWithDuration:duration animations:animations];
    }
    
    [self setVisibleRightBarButtonsForEditingMode:isEditing];
    _keyboardHeight = visibleHeight;
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
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    bDisableShrinkingNavigationBar = NO;

    [self.textLinkifier scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    // exand navigation bar if velocity is high enought
    if (velocity.y < -1.0) {
        [self resetNavigationBarToIdentityWithAnimation:YES completion:nil];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self.textLinkifier scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
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
    
    void (^animationBlock)();
    
    animationBlock = ^() {
        
        backButton.transform = CGAffineTransformIdentity;
        keyboardButton.transform = CGAffineTransformIdentity;
        newButton.transform = CGAffineTransformIdentity;
        newButton.alpha = 1.0;
        actionButton.transform = CGAffineTransformIdentity;
        actionButton.alpha = 1.0;
        keyboardButton.alpha = 1.0;
        self.navigationController.navigationBar.transform = navigationBarTransform;
        
        backButton.alpha = 1.0;
    };
    
    void (^completionBlock)();
    
    completionBlock = ^() {
        
        if (!_noteEditorTextView.dragging && !_noteEditorTextView.decelerating) {
            bDisableShrinkingNavigationBar = NO;
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
    
    if ([UIDevice isPad] || bVoiceoverEnabled) {
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
    

    backButton.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleAmount, scaleAmount),
                                                       CGAffineTransformMakeTranslation(yTransform / 4.0, -yTransform / 2.0));
    backButton.alpha = isPortrait ? 1.0 : alphaAmount;
    keyboardButton.transform =CGAffineTransformConcat(CGAffineTransformMakeScale(scaleAmount, scaleAmount),
                                                      CGAffineTransformMakeTranslation(0, -yTransform / 2.0));
    keyboardButton.alpha = isPortrait ? 1.0 : alphaAmount;
    newButton.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleAmount, scaleAmount),
                                                  CGAffineTransformMakeTranslation(0, -yTransform / 2.0));
    newButton.alpha = alphaAmount;
    
    actionButton.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleAmount, scaleAmount),
                                                  CGAffineTransformMakeTranslation(0, -yTransform / 2.0));
    actionButton.alpha = alphaAmount;
    
    
    self.navigationController.navigationBar.transform = navigationBarTransform;
    
    
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
            CGPoint bottomOffset = CGPointMake(0, _noteEditorTextView.contentSize.height - _noteEditorTextView.bounds.size.height);
            if (_noteEditorTextView.contentOffset.y < bottomOffset.y)
                [_noteEditorTextView setContentOffset:bottomOffset animated:YES];
        });
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [self cancelSaveTimers];
    [self save];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if (![URL containsHttpScheme]) {
        return YES;
    }
    
    if ([SFSafariViewController class]) {
        SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:sfvc animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:URL];
    }
    
    return NO;
}

- (BOOL)isDictatingText {
    NSString *inputMethod = _noteEditorTextView.textInputMode.primaryLanguage;
    if (inputMethod != nil) {
        return [inputMethod isEqualToString:@"dictation"];
    }

    return NO;
}

#pragma mark Note information

- (NSUInteger)wordCount {
    // countWordsInString returns -1 for a zero length string; handle that
    if (_noteEditorTextView.text == nil || [_noteEditorTextView.text length] == 0)
        return 0;
    
    __block NSUInteger wordCount = 0;
    [_noteEditorTextView.text enumerateSubstringsInRange:NSMakeRange(0, _noteEditorTextView.text.length)
                               options:NSStringEnumerationByWords
                            usingBlock:^(NSString *character, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                wordCount++;
                            }];
    return wordCount;}

- (NSUInteger)charCount {
    
    if (_noteEditorTextView.text == nil)
        return 0;
    
    return [_noteEditorTextView.text length];
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
        _currentNote.content = _noteEditorTextView.text;
        _currentNote.modificationDate = [NSDate date];

        // Force an update of the note's content preview in case only tags changed
        [_currentNote createPreview];
        
        
        // Simperum: save
        [[SPAppDelegate sharedDelegate] save];
        [SPTracker trackEditorNoteEdited];
        
        bModified = NO;
	}
}

- (void)willReceiveNewContent {
    
    cursorLocationBeforeRemoteUpdate = [_noteEditorTextView selectedRange].location;
    noteContentBeforeRemoteUpdate = _noteEditorTextView.text;
	
    if (_currentNote != nil && ![_noteEditorTextView.text isEqualToString:@""]) {
        _currentNote.content = _noteEditorTextView.text;
        [[SPAppDelegate sharedDelegate].simperium saveWithoutSyncing];
    }
}

- (void)didReceiveNewContent {
    
	NSUInteger newLocation = [self newCursorLocation:_currentNote.content
											 oldText:noteContentBeforeRemoteUpdate
									 currentLocation:cursorLocationBeforeRemoteUpdate];
	
	_noteEditorTextView.attributedText = [_currentNote.content attributedString];
	
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
    
    if ([sender isEqual:newButton]) {
        [SPTracker trackEditorNoteCreated];
    }

    
    bDisableShrinkingNavigationBar = YES; // disable the navigation bar shrinking to avoid weird animations
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kWillAddNewNote
                                                        object:self];
    
    // Save current note first MAY NOT NEED THIS IF NOTE CANNOT BE VISIABLE AT SAME TIME
    //    note.content = noteEditor.string;
    //    [self save];
    
	NSManagedObjectContext *context = [[SPAppDelegate sharedDelegate] managedObjectContext];
    Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
    newNote.modificationDate = [NSDate date];
    newNote.creationDate = [NSDate date];

    // Set the note's markdown tag according to the global preference (defaults NO for new accounts)
    newNote.markdown = [[NSUserDefaults standardUserDefaults] boolForKey:kSimplenoteMarkdownDefaultKey];

    NSString *currentTag = [[SPAppDelegate sharedDelegate] selectedTag];
    if ([currentTag length] > 0) {
        [newNote addTag:currentTag];
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
                             self.tagView.alpha = 1.0;

                         } completion:^(BOOL finished) {
                             
                             [snapshot removeFromSuperview];
                             
                         }];
        
    } else {
        
        [self updateNote:newNote];
        bBlankNote = YES;
    }
    

    dispatch_async(dispatch_get_main_queue(), ^{
        [_noteEditorTextView becomeFirstResponder];
    });
    
    bDisableShrinkingNavigationBar = NO;
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
    actionImages = @[[UIImage imageNamed:@"button_share_note"],
                     [UIImage imageNamed:@"icon_history"],
                     [UIImage imageNamed:@"button_collaborate"],
                     [UIImage imageNamed:@"icon_trash_large"]];
    toggleTitles = @[NSLocalizedString(@"Publish", @"Verb - Publishing a note creates  URL and for any note in a user's account, making it viewable to others"),
                    NSLocalizedString(@"Pin to Top", @"Denotes when note is pinned to the top of the note list"), NSLocalizedString(@"Markdown", @"Special formatting that can be turned on for notes")];
    toggleSelectedTitles = @[NSLocalizedString(@"Published", nil),
                             NSLocalizedString(@"Pinned", @"Pinned notes are stuck to the note of the note list"),
                             NSLocalizedString(@"Markdown", @"Special formatting that can be turned on for notes")];
    
    buttonStrings = @[NSLocalizedString(@"Note not published", nil)];
    
    NSInteger wordCount = [self wordCount];
    
    NSString *statusFormat = wordCount == 1 ? NSLocalizedString(@"%d Word", @"Number of words in a note") : NSLocalizedString(@"%d Words", @"Number of words in a note");
    NSString *status = [NSString stringWithFormat:statusFormat, wordCount];
    
    
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

        UIColor *actionSheetColor = [[self.theme colorForKey:@"actionSheetBackgroundColor"] colorWithAlphaComponent:0.97];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet isEqual:deleteActionSheet] && buttonIndex == 0) {
        bShouldDelete = YES;
        [self trashNoteAction:nil];
    }
}

#pragma mark Note Actions

- (CGRect)presentationRectForActionButton {
    
    return [self.view convertRect:actionButton.frame
                         fromView:actionButton.superview];
    
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
	   
    UISimpleTextPrintFormatter *print = [[UISimpleTextPrintFormatter alloc] initWithText:_currentNote.content];

    UIActivityViewController *acv = [[UIActivityViewController alloc] initWithActivityItems:@[_currentNote.content, print]
                                                                      applicationActivities:nil];
    
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
    
    bShouldDelete = YES; // quick way to disable action sheet confirmat.
    // can re-enable in the future
    
    // have prompt to make sure user wants to delete
    if (!bShouldDelete) {
        
        deleteActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          destructiveButtonTitle:NSLocalizedString(@"Trash-verb", @"Trash (verb) - the action of deleting a note")
                                               otherButtonTitles:nil];
        
        if ([UIDevice isPad]) {
            [deleteActionSheet showFromRect:[self presentationRectForActionButton]
                                     inView:self.view
                                   animated:YES];
        } else {
            [deleteActionSheet showInView:self.navigationController.view];
        }
        
        
    } else {
        
        bShouldDelete = NO;
    
        // create a snapshot before the animation
        UIView *snapshot = [_noteEditorTextView snapshotViewAfterScreenUpdates:NO];
        snapshot.frame = _noteEditorTextView.frame;
        [self.view addSubview:snapshot];
        
        [[SPObjectManager sharedManager] trashNote:_currentNote];
        
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

- (void)tagViewWillBeginEditing:(SPTagView *)tagView {

    _noteEditorTextView.lockContentOffset = YES;
}
- (void)tagViewDidBeginEditing:(SPTagView *)tagView {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_noteEditorTextView scrollToBottom];
    });
}

- (void)tagViewDidChange:(SPTagView *)tagView {
    [_noteEditorTextView scrollToBottom];
}

- (void)tagViewDidEndEditing:(SPTagView *)tagView {

    _noteEditorTextView.lockContentOffset = NO;
    [_noteEditorTextView resignFirstResponder]; // seems to fix some jumping of the text view
}

- (void)tagView:(SPTagView *)tagView didCreateTagName:(NSString *)tagName {
    
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
