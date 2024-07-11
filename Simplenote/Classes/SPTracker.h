#import <Foundation/Foundation.h>


/**
 *  @class      SPTracker
 *  @brief      This class is meant to aid in the app's event tracking. We'll relay the appropriate events to
 *              either Automattic Tracks, or Google Analytics.
 */

@interface SPTracker : NSObject

#pragma mark - Metadata
+ (void)refreshMetadataWithEmail:(NSString *)email;
+ (void)refreshMetadataForAnonymousUser;

#pragma mark - Application State
+ (void)trackApplicationOpened;
+ (void)trackApplicationClosed;

#pragma mark - Note Editor
+ (void)trackEditorChecklistInserted;
+ (void)trackEditorNoteCreated;
+ (void)trackEditorNoteDeleted;
+ (void)trackEditorNoteRestored;
+ (void)trackEditorNotePublishEnabled:(BOOL)isOn;
+ (void)trackEditorNoteContentShared;
+ (void)trackEditorNoteEdited;
+ (void)trackEditorEmailTagAdded;
+ (void)trackEditorEmailTagRemoved;
+ (void)trackEditorTagAdded;
+ (void)trackEditorTagRemoved;
+ (void)trackEditorNotePinEnabled:(BOOL)isOn;
+ (void)trackEditorNoteMarkdownEnabled:(BOOL)isOn;
+ (void)trackEditorActivitiesAccessed;
+ (void)trackEditorVersionsAccessed;
+ (void)trackEditorCollaboratorsAccessed;
+ (void)trackEditorCopiedInternalLink;
+ (void)trackEditorCopiedPublicLink;
+ (void)trackEditorInterlinkAutocompleteViewed;

#pragma mark - Note List
+ (void)trackListNoteCreated;
+ (void)trackListNoteDeleted;
+ (void)trackListNoteOpened;
+ (void)trackListTrashEmptied;
+ (void)trackListNotesSearched;
+ (void)trackListPinToggled;
+ (void)trackListCopiedInternalLink;
+ (void)trackListTagViewed;
+ (void)trackListUntaggedViewed;
+ (void)trackTrashViewed;

#pragma mark - Preferences
+ (void)trackSettingsPinlockEnabled:(BOOL)isOn;
+ (void)trackSettingsListCondensedEnabled:(BOOL)isOn;
+ (void)trackSettingsNoteListSortMode:(NSString *)description;
+ (void)trackSettingsThemeUpdated:(NSString *)themeName;

#pragma mark - Sidebar
+ (void)trackSidebarSidebarPanned;
+ (void)trackSidebarButtonPresed;

#pragma mark - Tag List
+ (void)trackTagRowRenamed;
+ (void)trackTagRowDeleted;
+ (void)trackTagCellPressed;
+ (void)trackTagMenuRenamed;
+ (void)trackTagMenuDeleted;
+ (void)trackTagEditorAccessed;

#pragma mark - Ratings
+ (void)trackRatingsPromptSeen;
+ (void)trackRatingsAppRated;
+ (void)trackRatingsAppLiked;
+ (void)trackRatingsAppDisliked;
+ (void)trackRatingsDeclinedToRate;
+ (void)trackRatingsFeedbackScreenOpened;
+ (void)trackRatingsFeedbackSent;
+ (void)trackRatingsFeedbackDeclined;

#pragma mark - User
+ (void)trackUserAccountCreated;
+ (void)trackUserSignedIn;
+ (void)trackUserSignedOut;

#pragma mark - Login Links
+ (void)trackLoginLinkRequested;
+ (void)trackLoginLinkConfirmationSuccess;
+ (void)trackLoginLinkConfirmationFailure;

#pragma mark - WP.com Sign In
+ (void)trackWPCCButtonPressed;
+ (void)trackWPCCLoginSucceeded;
+ (void)trackWPCCLoginFailed;

#pragma mark -

+ (void)trackAutomatticEventWithName:(NSString *)name
                          properties:(NSDictionary *)properties;

@end
