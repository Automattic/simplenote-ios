#import <UIKit/UIKit.h>
#import <Simperium/Simperium.h>


@class Note;
@class SPBlurEffectView;
@class SPEditorTextView;

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

// Voiceover
@property (nonatomic, strong) UIView *bottomView;

// Keyboard!
@property (nonatomic, strong) NSArray *keyboardNotificationTokens;
@property (nonatomic) BOOL isKeyboardVisible;

// State
@property (nonatomic, getter=isEditingNote) BOOL editingNote;
@property (nonatomic, getter=isPreviewing) BOOL previewing;
@property (nonatomic, assign) BOOL blankNote;


- (void)prepareToPopView;
- (void)displayNote:(Note *)note;
- (void)setSearchString:(NSString *)string;
- (void)clearNote;
- (void)endEditing;
- (void)bounceMarkdownPreview;

- (void)willReceiveNewContent;
- (void)didReceiveNewContent;
- (void)didReceiveVersion:(NSString *)version data:(NSDictionary *)data;
- (void)didDeleteCurrentNote;

- (void)presentCollaboratorsController;
- (void)presentHistoryController;
- (void)trashNoteAction;

- (void)resetNavigationBarToIdentityWithAnimation:(BOOL)animated completion:(void (^)())completion;

- (void)save;

@end
