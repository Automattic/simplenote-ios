#import <UIKit/UIKit.h>
#import <Simperium/Simperium.h>


@class InterlinkProcessor;
@class Note;
@class SPBlurEffectView;
@class SPEditorTextView;
@class SPTagView;
@class SearchMapView;
@class NoteEditorTagListViewController;
@class NoteScrollPositionCache;

NS_ASSUME_NONNULL_BEGIN

@interface SPNoteEditorViewController : UIViewController  <SPBucketDelegate>

// Navigation Bar
@property (nonatomic, strong, readonly) SPBlurEffectView *navigationBarBackground;

// Navigation Buttons
@property (nonatomic, strong) UIBarButtonItem *actionButton;
@property (nonatomic, strong) UIBarButtonItem *checklistButton;
@property (nonatomic, strong) UIBarButtonItem *keyboardButton;
@property (nonatomic, strong) UIBarButtonItem *createNoteButton;
@property (nonatomic, strong) UIBarButtonItem *informationButton;

@property (nonatomic, strong, readonly) Note *note;
@property (nonatomic, strong) SPEditorTextView *noteEditorTextView;

@property (nonatomic, strong) NoteEditorTagListViewController *tagListViewController;
@property (nonatomic, strong) NSLayoutConstraint *tagListBottomConstraint;

// History
@property (nonatomic, weak) UIViewController * _Nullable historyViewController;

// Information
@property (nonatomic, weak) UIViewController * _Nullable informationViewController;

// Interlinks
@property (nonatomic, strong) InterlinkProcessor *interlinkProcessor;

// Keyboard!
@property (nonatomic, strong) NSArray * _Nullable keyboardNotificationTokens;
@property (nonatomic) BOOL isKeyboardVisible;

@property (nonatomic, strong) SearchMapView * _Nullable searchMapView;

// State
@property (nonatomic, getter=isEditingNote) BOOL editingNote;
@property (nonatomic, getter=isPreviewing) BOOL previewing;
@property (nonatomic, assign) BOOL modified;
@property (nonatomic, readonly) BOOL searching;
@property (nonatomic, assign) NSInteger highlightedSearchResultIndex;

@property (nonatomic, strong) NoteScrollPositionCache *scrollPositionCache;

- (instancetype)initWithNote:(Note *)note;

- (void)dismissEditor:(id _Nullable )sender;
- (void)insertChecklistAction:(id _Nullable )sender;
- (void)keyboardButtonAction:(id _Nullable )sender;

- (void)endEditing;
- (void)bounceMarkdownPreview;

- (void)ensureSearchIsDismissed;
- (void)highlightSearchResultAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)highlightNextSearchResult;
- (void)highlightPrevSearchResult;

- (void)willReceiveNewContent;
- (void)didReceiveNewContent;
- (void)didDeleteCurrentNote;

- (void)save;
- (void)saveIfNeeded;

// TODO: We can't use `SearchQuery` as a type here because it doesn't work from swift code (because of SPM) :-(
- (void)updateWithSearchQuery:(id _Nullable )query;

@end

NS_ASSUME_NONNULL_END
