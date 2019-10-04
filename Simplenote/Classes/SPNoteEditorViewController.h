#import <UIKit/UIKit.h>
#import "SPActionSheet.h"
#import "SPActivityView.h"
#import "SPTagView.h"
#import "SPAddCollaboratorsViewController.h"
#import "SPHorizontalPickerView.h"
#import <Simperium/Simperium.h>
@class Note;
@class SPTextView;
@class SPEditorTextView;
@class SPOutsideTouchView;

@interface SPNoteEditorViewController : UIViewController  <UITextViewDelegate, SPActionSheetDelegate, SPActivityViewDelegate, UIActionSheetDelegate, SPTagViewDelegate, SPCollaboratorDelegate, SPHorizontalPickerViewDelegate, SPBucketDelegate> {
    
    // Other Objects
    NSTimer *saveTimer;
    NSTimer *guarenteedSaveTimer;
    
    // BOOLS
    BOOL bBlankNote;
    BOOL bModified;
    BOOL bDisableShrinkingNavigationBar;
    BOOL bShouldDelete;
    BOOL bViewingVersions;
    BOOL beditingTags;
    BOOL bActionSheetVisible;
    BOOL bVoiceoverEnabled;
    
    CGAffineTransform navigationBarTransform;
    CGFloat scrollPosition;
    
    SPOutsideTouchView *navigationButtonContainer;
    UIButton *backButton;
    UIButton *actionButton;
    UIButton *newButton;
    UIButton *keyboardButton;
    UIButton *checklistButton;
    
    UIBarButtonItem *nextSearchButton;
    UIBarButtonItem *prevSearchButton;
    UIBarButtonItem *doneSearchButton;
    
    // sheets
    SPActivityView *noteActivityView;
    SPActionSheet *noteActionSheet;
    SPActionSheet *versionActionSheet;
    
    SPHorizontalPickerView *versionPickerView;
    
    BOOL bSearching;
    NSArray *searchResultRanges;
    NSInteger highlightedSearchResultIndex;
    
    UILabel *searchDetailLabel;
    
    NSInteger currentVersion;
    NSMutableDictionary *noteVersionData;
    
}

@property (nonatomic, strong) Note *currentNote;
@property (nonatomic, strong) SPEditorTextView *noteEditorTextView;
@property (nonatomic, strong) SPTagView *tagView;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, assign) BOOL isPreviewing;

- (void)prepareToPopView;
- (void)updateNote:(Note *)note;
- (void)setSearchString:(NSString *)string;
- (void)clearNote;

- (void)willReceiveNewContent;
- (void)didReceiveNewContent;
- (void)didReceiveVersion:(NSString *)version data:(NSDictionary *)data;
- (void)didDeleteCurrentNote;

- (void)save;

@end
