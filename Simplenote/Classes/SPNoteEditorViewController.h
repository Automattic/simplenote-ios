#import <UIKit/UIKit.h>
#import "SPActionSheet.h"
#import "SPActivityView.h"
#import "SPTagView.h"
#import "SPAddCollaboratorsViewController.h"
#import <Simperium/Simperium.h>


@class Note;
@class SPBlurEffectView;
@class SPTextView;
@class SPEditorTextView;
@class SPOutsideTouchView;
@class SPHistoryLoader;

@interface SPNoteEditorViewController : UIViewController  <SPActionSheetDelegate, SPActivityViewDelegate, UIActionSheetDelegate, SPTagViewDelegate, SPCollaboratorDelegate> {
    
    // Other Objects
    NSTimer *saveTimer;
    NSTimer *guarenteedSaveTimer;
    
    // BOOLS
    BOOL bBlankNote;
    BOOL bDisableShrinkingNavigationBar;
    BOOL bShouldDelete;
    BOOL beditingTags;
    BOOL bActionSheetVisible;
    
    CGAffineTransform navigationBarTransform;
    CGFloat scrollPosition;
    
    SPOutsideTouchView *navigationButtonContainer;
    
    UIBarButtonItem *nextSearchButton;
    UIBarButtonItem *prevSearchButton;
    UIBarButtonItem *doneSearchButton;
    
    // sheets
    SPActivityView *noteActivityView;
    SPActionSheet *noteActionSheet;
    
    BOOL bSearching;
    NSInteger highlightedSearchResultIndex;
    
    UILabel *searchDetailLabel;
}

// Navigation Bar
@property (nonatomic, strong, readonly) SPBlurEffectView *navigationBarBackground;

// Navigation Back Button
@property (nonatomic, strong) UIButton *backButton;

// Navigation Buttons
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIButton *checklistButton;
@property (nonatomic, strong) UIButton *keyboardButton;
@property (nonatomic, strong) UIButton *createNoteButton;

@property (nonatomic, strong) Note *currentNote;
@property (nonatomic, strong) SPEditorTextView *noteEditorTextView;
@property (nonatomic, strong) SPTagView *tagView;
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

@property (nonatomic, getter=isEditingNote) BOOL editingNote;
@property (nonatomic, getter=isPreviewing) BOOL previewing;
@property (nonatomic, getter=isModified) BOOL modified;

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
