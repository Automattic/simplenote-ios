//
//  SPTracker.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/17/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

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

#pragma mark - Note Editor
+ (void)trackEditorNoteCreated;
+ (void)trackEditorNoteDeleted;
+ (void)trackEditorNoteRestored;
+ (void)trackEditorNotePublished;
+ (void)trackEditorNoteUnpublished;
+ (void)trackEditorPublishedUrlPressed;
+ (void)trackEditorNoteContentShared;
+ (void)trackEditorNoteEdited;
+ (void)trackEditorEmailTagAdded;
+ (void)trackEditorEmailTagRemoved;
+ (void)trackEditorTagAdded;
+ (void)trackEditorTagRemoved;
+ (void)trackEditorNotePinned;
+ (void)trackEditorNoteUnpinned;
+ (void)trackEditorNoteMarkdownEnabled;
+ (void)trackEditorNoteMarkdownDisabled;
+ (void)trackEditorActivitiesAccessed;
+ (void)trackEditorVersionsAccessed;
+ (void)trackEditorCollaboratorsAccessed;

#pragma mark - Note List
+ (void)trackListNoteCreated;
+ (void)trackListNoteDeleted;
+ (void)trackListNoteOpened;
+ (void)trackListTrashEmptied;
+ (void)trackListNotesSearched;
+ (void)trackListTagViewed;
+ (void)trackTrashViewed;

#pragma mark - Preferences
+ (void)trackSettingsPinlockEnabled:(BOOL)isOn;
+ (void)trackSettingsListCondensedEnabled:(BOOL)isOn;
+ (void)trackSettingsAlphabeticalSortEnabled:(BOOL)isOn;
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

#pragma mark - One Password
+ (void)trackOnePasswordLoginFailure;
+ (void)trackOnePasswordLoginSuccess;
+ (void)trackOnePasswordSignupFailure;
+ (void)trackOnePasswordSignupSuccess;

#pragma mark - User
+ (void)trackUserAccountCreated;
+ (void)trackUserSignedIn;
+ (void)trackUserSignedOut;

#pragma mark - Keychain Migration
+ (void)trackKeychainMigrationSucceeded;
+ (void)trackKeychainMigrationFailed;
+ (void)trackKeychainFailsafeSucceeded;
+ (void)trackKeychainFailsafeFailed;

#pragma mark - WP.com Sign In
+ (void)trackWPCCButtonPressed;
+ (void)trackWPCCLoginSucceeded;
+ (void)trackWPCCLoginFailed;

@end
