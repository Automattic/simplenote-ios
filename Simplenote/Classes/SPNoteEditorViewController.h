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

// Voiceover
@property (nonatomic, strong) UIView *bottomView;

// Keyboard!
@property (nonatomic, strong) NSArray *keyboardNotificationTokens;
@property (nonatomic) BOOL isKeyboardVisible;

// State
@property (nonatomic, getter=isEditingNote) BOOL editingNote;
@property (nonatomic, getter=isPreviewing) BOOL previewing;


- (void)backButtonAction:(id)sender;

- (void)displayNote:(Note *)note;
- (void)setSearchString:(NSString *)string;
- (void)clearNote;
- (void)endEditing;
- (void)bounceMarkdownPreview;

- (void)willReceiveNewContent;
- (void)didReceiveNewContent;
- (void)didReceiveVersion:(NSString *)version data:(NSDictionary *)data;
- (void)didDeleteCurrentNote;

- (void)presentHistoryController;

- (void)save;

@end
