#import <UIKit/UIKit.h>
#import <Simperium/Simperium.h>


@class Note;
@class SPBlurEffectView;
@class SPEditorTextView;
@class SPHistoryLoader;

@interface SPNoteEditorViewController : UIViewController  <SPBucketDelegate>

// Navigation Bar
@property (nonatomic, strong, readonly) SPBlurEffectView *navigationBarBackground;

// Navigation Buttons
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIButton *checklistButton;
@property (nonatomic, strong) UIButton *keyboardButton;
@property (nonatomic, strong) UIButton *createNoteButton;

@property (nonatomic, strong) Note *currentNote;
@property (nonatomic, strong) SPEditorTextView *noteEditorTextView;
@property (nonatomic, strong) NSString *searchString;

// History
@property (nonatomic, weak) UIViewController *historyViewController;
@property (nonatomic, weak) SPHistoryLoader *historyLoader;
@property (nonatomic, strong) id<UIViewControllerTransitioningDelegate> historyTransitioningManager;

// Voiceover
@property (nonatomic, strong) UIView *bottomView;

// Keyboard!
@property (nonatomic, strong) NSArray *keyboardNotificationTokens;
@property (nonatomic) BOOL isKeyboardVisible;

// State
@property (nonatomic, getter=isEditingNote) BOOL editingNote;
@property (nonatomic, getter=isPreviewing) BOOL previewing;
@property (nonatomic, assign) BOOL modified;

- (void)prepareToPopView;
- (void)displayNote:(Note *)note;
- (void)setSearchString:(NSString *)string;
- (void)clearNote;

- (void)willReceiveNewContent;
- (void)didReceiveNewContent;
- (void)didDeleteCurrentNote;

- (void)resetNavigationBarToIdentityWithAnimation:(BOOL)animated completion:(void (^)())completion;

- (void)save;

@end
