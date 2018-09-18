#import "SPTracker.h"
#import "SPAutomatticTracker.h"
#import "SPGoogleTracker.h"
#import "SPAppDelegate.h"
#import "Simperium+Simplenote.h"


@implementation SPTracker


#pragma mark - Metadata

+ (void)refreshMetadataWithEmail:(NSString *)email
{
    [[SPAutomatticTracker sharedInstance] refreshMetadataWithEmail:email];
    [[SPGoogleTracker sharedInstance] refreshMetadataWithEmail:email];
}

+ (void)refreshMetadataForAnonymousUser
{
    [[SPAutomatticTracker sharedInstance] refreshMetadataForAnonymousUser];
    [[SPGoogleTracker sharedInstance] refreshMetadataWithEmail:nil];
}


#pragma mark - Note Editor

+ (void)trackEditorNoteCreated
{
    [self trackAutomatticEventWithName:@"editor_note_created" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"created_note" label:@"editor_new_button" value:nil];
}

+ (void)trackEditorNoteDeleted
{
    [self trackAutomatticEventWithName:@"editor_note_deleted" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"deleted_note" label:@"editor_trash_button" value:nil];
}

+ (void)trackEditorNoteRestored
{
    [self trackAutomatticEventWithName:@"editor_note_restored" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"restored_version" label:@"restore_version_button" value:nil];
}

+ (void)trackEditorNotePublished
{
    [self trackAutomatticEventWithName:@"editor_note_published" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"published_note" label:@"publish_note_button" value:nil];
}

+ (void)trackEditorNoteUnpublished
{
    [self trackAutomatticEventWithName:@"editor_note_unpublished" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"unpublished_note" label:@"publish_note_button" value:nil];
}

+ (void)trackEditorPublishedUrlPressed
{
    [self trackAutomatticEventWithName:@"editor_note_published_url_pressed" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"shared_note_url" label:@"share_url_button" value:nil];
}

+ (void)trackEditorNoteContentShared
{
    [self trackAutomatticEventWithName:@"editor_note_content_shared" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"shared_note" label:@"share_button" value:nil];
}

+ (void)trackEditorNoteEdited
{
    [self trackAutomatticEventWithName:@"editor_note_edited" properties:nil];
}

+ (void)trackEditorEmailTagAdded
{
    [self trackAutomatticEventWithName:@"editor_email_tag_added" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"added_email_tag" label:@"collaborator_view" value:nil];
}

+ (void)trackEditorEmailTagRemoved
{
    [self trackAutomatticEventWithName:@"editor_email_tag_removed" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"removed_email_tag" label:@"collaborator_view" value:nil];
}

+ (void)trackEditorTagAdded
{
    [self trackAutomatticEventWithName:@"editor_tag_added" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"added_tag" label:@"tag_view" value:nil];
}

+ (void)trackEditorTagRemoved
{
    [self trackAutomatticEventWithName:@"editor_tag_removed" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"removed_tag" label:@"tag_view" value:nil];
}

+ (void)trackEditorNotePinned
{
    [self trackAutomatticEventWithName:@"editor_note_pinned" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"pinned_note" label:@"pin_note_button" value:nil];
}

+ (void)trackEditorNoteUnpinned
{
    [self trackAutomatticEventWithName:@"editor_note_unpinned" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"unpinned_note" label:@"pin_note_button" value:nil];
}

+ (void)trackEditorNoteMarkdownEnabled
{
    [self trackAutomatticEventWithName:@"editor_note_markdown_enabled" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"markdown_enabled" label:@"note_markdown_button" value:nil];
}

+ (void)trackEditorNoteMarkdownDisabled
{
    [self trackAutomatticEventWithName:@"editor_note_markdown_disabled" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"markdown_disabled" label:@"note_markdown_button" value:nil];
}

+ (void)trackEditorActivitiesAccessed
{
    [self trackAutomatticEventWithName:@"editor_activities_accessed" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"view_activities" label:@"view_activities_button" value:nil];
}

+ (void)trackEditorCollaboratorsAccessed
{
    [self trackAutomatticEventWithName:@"editor_collaborators_accessed" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"viewed_note_collaborators" label:@"view_collaborators_button" value:nil];
}

+ (void)trackEditorVersionsAccessed
{
    [self trackAutomatticEventWithName:@"editor_versions_accessed" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"viewed_versions" label:@"view_versions_button" value:nil];
}



#pragma mark - Note List

+ (void)trackListNoteCreated
{
    [self trackAutomatticEventWithName:@"list_note_created" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"created_note" label:@"note_list_new_button" value:nil];
}

+ (void)trackListNoteDeleted
{
    [self trackAutomatticEventWithName:@"list_note_deleted" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"deleted_note" label:@"note_cell_swipe" value:nil];
}

+ (void)trackListNoteOpened
{
    [self trackAutomatticEventWithName:@"list_note_opened" properties:nil];
    [self trackGoogleEventWithCategory:@"list" action:@"opened" label:@"note" value:nil];
}

+ (void)trackListTrashEmptied
{
    [self trackAutomatticEventWithName:@"list_trash_emptied" properties:nil];
    [self trackGoogleEventWithCategory:@"note" action:@"trash_emptied" label:@"empty_trash_button" value:nil];
}

+ (void)trackListNotesSearched
{
    [self trackAutomatticEventWithName:@"list_notes_searched" properties:nil];
    [self trackGoogleEventWithCategory:@"list" action:@"search" label:@"notes" value:nil];
}

+ (void)trackListTagViewed
{
    [self trackAutomatticEventWithName:@"list_tag_viewed" properties:nil];
    [self trackGoogleEventWithCategory:@"tag" action:@"viewed_notes_for_tag" label:@"tag_list_cell" value:nil];
}

+ (void)trackTrashViewed
{
    [self trackAutomatticEventWithName:@"list_trash_viewed" properties:nil];
    [self trackGoogleEventWithCategory:@"trash" action:@"viewed" label:nil value:nil];
}



#pragma mark - Preferences

+ (void)trackSettingsPinlockEnabled:(BOOL)isOn
{
    [self trackAutomatticEventWithName:@"settings_pinlock_enabled" properties:@{ @"enabled" : @(isOn) }];
    [self trackGoogleEventWithCategory:@"user" action:@"pin_lock_pref" label:nil value:@(isOn)];
}

+ (void)trackSettingsListCondensedEnabled:(BOOL)isOn
{
    [self trackAutomatticEventWithName:@"settings_list_condensed_enabled" properties:@{ @"enabled" : @(isOn) }];
    [self trackGoogleEventWithCategory:@"user" action:@"condensed_note_list_pref" label:nil value:@(isOn)];
}

+ (void)trackSettingsAlphabeticalSortEnabled:(BOOL)isOn
{
    [self trackAutomatticEventWithName:@"settings_alphabetical_sort_enabled" properties:@{ @"enabled" : @(isOn) }];
    [self trackGoogleEventWithCategory:@"user" action:@"alphabetical_sort_pref" label:nil value:@(isOn)];
}

+ (void)trackSettingsThemeUpdated:(NSString *)themeName
{
    NSParameterAssert(themeName);
    
    [self trackAutomatticEventWithName:@"settings_theme_updated" properties:@{ @"name" : themeName }];
    [self trackGoogleEventWithCategory:@"user" action:@"changed_theme" label:themeName value:nil];
}



#pragma mark - Sidebar

+ (void)trackSidebarSidebarPanned
{
    [self trackAutomatticEventWithName:@"sidebar_sidebar_panned" properties:nil];
    [self trackGoogleEventWithCategory:@"tag" action:@"view_tag_list" label:@"pan" value:nil];
}

+ (void)trackSidebarButtonPresed
{
    [self trackAutomatticEventWithName:@"sidebar_button_pressed" properties:nil];
    [self trackGoogleEventWithCategory:@"tag" action:@"view_tag_list" label:@"sidebar_button" value:nil];
}



#pragma mark - Tag List

+ (void)trackTagRowRenamed
{
    [self trackAutomatticEventWithName:@"tag_row_renamed" properties:nil];
    [self trackGoogleEventWithCategory:@"tag" action:@"renamed_tag" label:@"tags_edit_mode" value:nil];
}

+ (void)trackTagRowDeleted
{
    [self trackAutomatticEventWithName:@"tag_row_deleted" properties:nil];
    [self trackGoogleEventWithCategory:@"tag" action:@"deleted_tag" label:@"tags_edit_mode" value:nil];
}

+ (void)trackTagCellPressed
{
    [self trackAutomatticEventWithName:@"tag_cell_pressed" properties:nil];
    [self trackGoogleEventWithCategory:@"tag" action:@"long_press_cell" label:@"tag_list_cell" value:nil];
}

+ (void)trackTagMenuRenamed
{
    [self trackAutomatticEventWithName:@"tag_menu_renamed" properties:nil];
    [self trackGoogleEventWithCategory:@"tag" action:@"renamed_tag" label:@"tag_cell_menu" value:nil];
}

+ (void)trackTagMenuDeleted
{
    [self trackAutomatticEventWithName:@"tag_menu_deleted" properties:nil];
    [self trackGoogleEventWithCategory:@"tag" action:@"deleted_tag" label:@"tag_cell_menu" value:nil];
}

+ (void)trackTagEditorAccessed
{
    [self trackAutomatticEventWithName:@"tag_editor_accessed" properties:nil];
    [self trackGoogleEventWithCategory:@"tag" action:@"entered_edit_mode" label:@"tag_list_edit_button" value:nil];
}



#pragma mark - Ratings

+ (void)trackRatingsPromptSeen
{
    [self trackAutomatticEventWithName:@"ratings_prompt_seen" properties:nil];
    [self trackGoogleEventWithCategory:@"ratings" action:@"user_saw_prompt" label:nil value:nil];
}

+ (void)trackRatingsAppRated
{
    [self trackAutomatticEventWithName:@"ratings_app_rated" properties:nil];
    [self trackGoogleEventWithCategory:@"ratings" action:@"user_rated_app" label:nil value:nil];
}

+ (void)trackRatingsAppLiked
{
    [self trackAutomatticEventWithName:@"ratings_app_liked" properties:nil];
    [self trackGoogleEventWithCategory:@"ratings" action:@"liked_app" label:nil value:nil];
}

+ (void)trackRatingsAppDisliked
{
    [self trackAutomatticEventWithName:@"ratings_app_disliked" properties:nil];
    [self trackGoogleEventWithCategory:@"ratings" action:@"disliked_app" label:nil value:nil];
}

+ (void)trackRatingsDeclinedToRate
{
    [self trackAutomatticEventWithName:@"ratings_declined_to_rate_app" properties:nil];
    [self trackGoogleEventWithCategory:@"ratings" action:@"user_declined_to_rate" label:nil value:nil];
}

+ (void)trackRatingsFeedbackScreenOpened
{
    [self trackAutomatticEventWithName:@"ratings_feedback_screen_opened" properties:nil];
    [self trackGoogleEventWithCategory:@"ratings" action:@"feedback_screen_shown" label:nil value:nil];
}

+ (void)trackRatingsFeedbackSent
{
    [self trackAutomatticEventWithName:@"ratings_feedback_sent" properties:nil];
    [self trackGoogleEventWithCategory:@"ratings" action:@"feedback_sent" label:nil value:nil];
}

+ (void)trackRatingsFeedbackDeclined
{
    [self trackAutomatticEventWithName:@"ratings_feedback_declined" properties:nil];
    [self trackGoogleEventWithCategory:@"ratings" action:@"feedback_cancelled" label:nil value:nil];
}



#pragma mark - One Password

+ (void)trackOnePasswordLoginSuccess
{
    [self trackAutomatticEventWithName:@"one_password_login_succeeded" properties:nil];
    [self trackGoogleEventWithCategory:@"one_password" action:@"login" label:@"success" value:nil];
}

+ (void)trackOnePasswordLoginFailure
{
    [self trackAutomatticEventWithName:@"one_password_login_failed" properties:nil];
    [self trackGoogleEventWithCategory:@"one_password" action:@"login" label:@"failure" value:nil];
}

+ (void)trackOnePasswordSignupSuccess
{
    [self trackAutomatticEventWithName:@"one_password_signup_succeeded" properties:nil];
    [self trackGoogleEventWithCategory:@"one_password" action:@"signup" label:@"success" value:nil];
}

+ (void)trackOnePasswordSignupFailure
{
    [self trackAutomatticEventWithName:@"one_password_signup_failed" properties:nil];
    [self trackGoogleEventWithCategory:@"one_password" action:@"signup" label:@"failure" value:nil];
}



#pragma mark - User

+ (void)trackUserAccountCreated
{
    [self trackAutomatticEventWithName:@"user_account_created" properties:nil];
    [self trackGoogleEventWithCategory:@"user" action:@"created" label:@"account" value:nil];
}

+ (void)trackUserSignedIn
{
    [self trackAutomatticEventWithName:@"user_signed_in" properties:nil];
    [self trackGoogleEventWithCategory:@"user" action:@"signed_in" label:nil value:nil];
}

+ (void)trackUserSignedOut
{
    [self trackAutomatticEventWithName:@"user_signed_out" properties:nil];
    [self trackGoogleEventWithCategory:@"user" action:@"signed_out" label:nil value:nil];
}

#pragma mark - Keychain Migration

+ (void)trackKeychainMigrationSucceeded
{
    [self trackAutomatticEventWithName:@"keychain_migration_succeeded" properties:nil];
    [self trackGoogleEventWithCategory:@"keychain" action:@"migraiton" label:@"success" value:nil];
}

+ (void)trackKeychainMigrationFailed
{
    [self trackAutomatticEventWithName:@"keychain_migration_failed" properties:nil];
    [self trackGoogleEventWithCategory:@"keychain" action:@"migration" label:@"failure" value:nil];
}

+ (void)trackKeychainFailsafeSucceeded
{
    [self trackAutomatticEventWithName:@"keychain_failsafe_succeeded" properties:nil];
    [self trackGoogleEventWithCategory:@"keychain" action:@"failsafe" label:@"succeeded" value:nil];
}

+ (void)trackKeychainFailsafeFailed
{
    [self trackAutomatticEventWithName:@"keychain_failsafe_failed" properties:nil];
    [self trackGoogleEventWithCategory:@"keychain" action:@"failsafe" label:@"failure" value:nil];
}

#pragma mark - WP.com Sign In

+ (void)trackWPCCButtonPressed
{
    [self trackAutomatticEventWithName:@"wpcc_button_pressed" properties:nil];
}

+ (void)trackWPCCLoginSucceeded
{
    [self trackAutomatticEventWithName:@"wpcc_login_succeeded" properties:nil];
}

+ (void)trackWPCCLoginFailed
{
    [self trackAutomatticEventWithName:@"wpcc_login_failed" properties:nil];
}


#pragma mark - Google Analytics Helpers

+ (void)trackAutomatticEventWithName:(NSString *)name
                          properties:(NSDictionary *)properties
{
    if ([self isTrackingDisabled]) {
        return;
    }
    [[SPAutomatticTracker sharedInstance] trackEventWithName:name properties:properties];
}



#pragma mark - Automattic Tracks Helpers

+ (void)trackGoogleEventWithCategory:(NSString *)category
                              action:(NSString *)action
                               label:(NSString *)label
                               value:(NSNumber *)value
{
    if ([self isTrackingDisabled]) {
        return;
    }
    [[SPGoogleTracker sharedInstance] trackEventWithCategory:category action:action label:label value:value];
}


+ (BOOL)isTrackingDisabled
{
    Preferences *preferences = [[[SPAppDelegate sharedDelegate] simperium] preferencesObject];
    NSNumber *enabled = [preferences analytics_enabled];

    return [enabled boolValue] == false;
}

@end
