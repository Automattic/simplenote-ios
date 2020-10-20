#import <UIKit/UIKit.h>
#import <Simperium/Simperium.h>


@class Note;
@class SPBlurEffectView;
@class SPEditorTextView;

@interface SPNoteEditorViewController : UIViewController  <SPBucketDelegate>

// Navigation Bar
@property (nonatomic, strong, readonly) SPBlurEffectView *navigationBarBackground;

// Navigation Buttons
@property (nonatomic, strong) UIBarButtonItem *actionButton;
@property (nonatomic, strong) UIBarButtonItem *checklistButton;
@property (nonatomic, strong) UIBarButtonItem *keyboardButton;
@property (nonatomic, strong) UIBarButtonItem *createNoteButton;

@property (nonatomic, strong) Note *currentNote;
@property (nonatomic, strong) SPEditorTextView *noteEditorTextView;
@property (nonatomic, strong) NSString *searchString;

// History
@property (nonatomic, weak) UIViewController *historyViewController;

// Voiceover
@property (nonatomic, strong) UIView *bottomView;

// Keyboard!
@property (nonatomic, strong) NSArray *keyboardNotificationTokens;
@property (nonatomic) BOOL isKeyboardVisible;

// State
@property (nonatomic, getter=isEditingNote) BOOL editingNote;
@property (nonatomic, getter=isPreviewing) BOOL previewing;
@property (nonatomic, assign) BOOL modified;

- (void)dismissEditor:(id)sender;
- (void)insertChecklistAction:(id)sender;
- (void)keyboardButtonAction:(id)sender;
- (void)newButtonAction:(id)sender;

- (void)displayNote:(Note *)note;
- (void)setSearchString:(NSString *)string;
- (void)clearNote;
- (void)endEditing;
- (void)bounceMarkdownPreview;

- (void)ensureSearchIsDismissed;

- (void)willReceiveNewContent;
- (void)didReceiveNewContent;
- (void)didDeleteCurrentNote;

- (void)save;

@end
