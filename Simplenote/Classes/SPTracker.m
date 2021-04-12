#import "SPTracker.h"
#import "SPAutomatticTracker.h"
#import "SPAppDelegate.h"
#import "Simperium+Simplenote.h"


@implementation SPTracker


#pragma mark - Metadata

+ (void)refreshMetadataWithEmail:(NSString *)email
{
    [[SPAutomatticTracker sharedInstance] refreshMetadataWithEmail:email];
}

+ (void)refreshMetadataForAnonymousUser
{
    [[SPAutomatticTracker sharedInstance] refreshMetadataForAnonymousUser];
}


#pragma mark - Application State

+ (void)trackApplicationOpened
{
    [self trackAutomatticEventWithName:@"application_opened" properties:nil];
}

+ (void)trackApplicationClosed
{
    [self trackAutomatticEventWithName:@"application_closed" properties:nil];
}


#pragma mark - Note Editor

+ (void)trackEditorNoteCreated
{
    [self trackAutomatticEventWithName:@"editor_note_created" properties:nil];
}

+ (void)trackEditorNoteDeleted
{
    [self trackAutomatticEventWithName:@"editor_note_deleted" properties:nil];
}

+ (void)trackEditorNoteRestored
{
    [self trackAutomatticEventWithName:@"editor_note_restored" properties:nil];
}

+ (void)trackEditorNotePublishEnabled:(BOOL)isOn
{
    NSString *name = isOn ? @"editor_note_published" : @"editor_note_unpublished";
    [self trackAutomatticEventWithName:name properties:nil];
}

+ (void)trackEditorNoteContentShared
{
    [self trackAutomatticEventWithName:@"editor_note_content_shared" properties:nil];
}

+ (void)trackEditorNoteEdited
{
    [self trackAutomatticEventWithName:@"editor_note_edited" properties:nil];
}

+ (void)trackEditorEmailTagAdded
{
    [self trackAutomatticEventWithName:@"editor_email_tag_added" properties:nil];
}

+ (void)trackEditorEmailTagRemoved
{
    [self trackAutomatticEventWithName:@"editor_email_tag_removed" properties:nil];
}

+ (void)trackEditorTagAdded
{
    [self trackAutomatticEventWithName:@"editor_tag_added" properties:nil];
}

+ (void)trackEditorTagRemoved
{
    [self trackAutomatticEventWithName:@"editor_tag_removed" properties:nil];
}

+ (void)trackEditorNotePinEnabled:(BOOL)isOn
{
    NSString *name = isOn ? @"editor_note_pinned" : @"editor_note_unpinned";
    [self trackAutomatticEventWithName:name properties:nil];
}

+ (void)trackEditorNoteMarkdownEnabled:(BOOL)isOn
{
    NSString *name = isOn ? @"editor_note_markdown_enabled" : @"editor_note_markdown_disabled";
    [self trackAutomatticEventWithName:name properties:nil];
}

+ (void)trackEditorActivitiesAccessed
{
    [self trackAutomatticEventWithName:@"editor_activities_accessed" properties:nil];
}

+ (void)trackEditorChecklistInserted
{
    [self trackAutomatticEventWithName:@"editor_checklist_inserted" properties:nil];
}

+ (void)trackEditorCollaboratorsAccessed
{
    [self trackAutomatticEventWithName:@"editor_collaborators_accessed" properties:nil];
}

+ (void)trackEditorVersionsAccessed
{
    [self trackAutomatticEventWithName:@"editor_versions_accessed" properties:nil];
}

+ (void)trackEditorCopiedInternalLink
{
    [self trackAutomatticEventWithName:@"editor_copied_internal_link" properties:nil];
}

+ (void)trackEditorCopiedPublicLink
{
    [self trackAutomatticEventWithName:@"editor_copied_public_link" properties:nil];
}

+ (void)trackEditorInterlinkAutocompleteViewed
{
    [self trackAutomatticEventWithName:@"editor_interlink_autocomplete_viewed" properties:nil];
}


#pragma mark - Note List

+ (void)trackListNoteCreated
{
    [self trackAutomatticEventWithName:@"list_note_created" properties:nil];
}

+ (void)trackListNoteDeleted
{
    [self trackAutomatticEventWithName:@"list_note_deleted" properties:nil];
}

+ (void)trackListNoteOpened
{
    [self trackAutomatticEventWithName:@"list_note_opened" properties:nil];
}

+ (void)trackListTrashEmptied
{
    [self trackAutomatticEventWithName:@"list_trash_emptied" properties:nil];
}

+ (void)trackListNotesSearched
{
    [self trackAutomatticEventWithName:@"list_notes_searched" properties:nil];
}

+ (void)trackListPinToggled
{
    [self trackAutomatticEventWithName:@"list_note_toggled_pin" properties:nil];
}

+ (void)trackListCopiedInternalLink
{
    [self trackAutomatticEventWithName:@"list_copied_internal_link" properties:nil];
}

+ (void)trackListTagViewed
{
    [self trackAutomatticEventWithName:@"list_tag_viewed" properties:nil];
}

+ (void)trackListUntaggedViewed
{
    [self trackAutomatticEventWithName:@"list_untagged_viewed" properties:nil];
}

+ (void)trackTrashViewed
{
    [self trackAutomatticEventWithName:@"list_trash_viewed" properties:nil];
}



#pragma mark - Preferences

+ (void)trackSettingsPinlockEnabled:(BOOL)isOn
{
    [self trackAutomatticEventWithName:@"settings_pinlock_enabled" properties:@{ @"enabled" : @(isOn) }];
}

+ (void)trackSettingsListCondensedEnabled:(BOOL)isOn
{
    [self trackAutomatticEventWithName:@"settings_list_condensed_enabled" properties:@{ @"enabled" : @(isOn) }];
}

+ (void)trackSettingsNoteListSortMode:(NSString *)description
{
    [self trackAutomatticEventWithName:@"settings_note_list_sort_mode" properties:@{ @"description" : description }];
}

+ (void)trackSettingsThemeUpdated:(NSString *)themeName
{
    NSParameterAssert(themeName);
    
    [self trackAutomatticEventWithName:@"settings_theme_updated" properties:@{ @"name" : themeName }];
}



#pragma mark - Sidebar

+ (void)trackSidebarSidebarPanned
{
    [self trackAutomatticEventWithName:@"sidebar_sidebar_panned" properties:nil];
}

+ (void)trackSidebarButtonPresed
{
    [self trackAutomatticEventWithName:@"sidebar_button_pressed" properties:nil];
}



#pragma mark - Tag List

+ (void)trackTagRowRenamed
{
    [self trackAutomatticEventWithName:@"tag_row_renamed" properties:nil];
}

+ (void)trackTagRowDeleted
{
    [self trackAutomatticEventWithName:@"tag_row_deleted" properties:nil];
}

+ (void)trackTagCellPressed
{
    [self trackAutomatticEventWithName:@"tag_cell_pressed" properties:nil];
}

+ (void)trackTagMenuRenamed
{
    [self trackAutomatticEventWithName:@"tag_menu_renamed" properties:nil];
}

+ (void)trackTagMenuDeleted
{
    [self trackAutomatticEventWithName:@"tag_menu_deleted" properties:nil];
}

+ (void)trackTagEditorAccessed
{
    [self trackAutomatticEventWithName:@"tag_editor_accessed" properties:nil];
}



#pragma mark - Ratings

+ (void)trackRatingsPromptSeen
{
    [self trackAutomatticEventWithName:@"ratings_prompt_seen" properties:nil];
}

+ (void)trackRatingsAppRated
{
    [self trackAutomatticEventWithName:@"ratings_app_rated" properties:nil];
}

+ (void)trackRatingsAppLiked
{
    [self trackAutomatticEventWithName:@"ratings_app_liked" properties:nil];
}

+ (void)trackRatingsAppDisliked
{
    [self trackAutomatticEventWithName:@"ratings_app_disliked" properties:nil];
}

+ (void)trackRatingsDeclinedToRate
{
    [self trackAutomatticEventWithName:@"ratings_declined_to_rate_app" properties:nil];
}

+ (void)trackRatingsFeedbackScreenOpened
{
    [self trackAutomatticEventWithName:@"ratings_feedback_screen_opened" properties:nil];
}

+ (void)trackRatingsFeedbackSent
{
    [self trackAutomatticEventWithName:@"ratings_feedback_sent" properties:nil];
}

+ (void)trackRatingsFeedbackDeclined
{
    [self trackAutomatticEventWithName:@"ratings_feedback_declined" properties:nil];
}


#pragma mark - User

+ (void)trackUserAccountCreated
{
    [self trackAutomatticEventWithName:@"user_account_created" properties:nil];
}

+ (void)trackUserSignedIn
{
    [self trackAutomatticEventWithName:@"user_signed_in" properties:nil];
}

+ (void)trackUserSignedOut
{
    [self trackAutomatticEventWithName:@"user_signed_out" properties:nil];
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

+ (BOOL)isTrackingDisabled
{
    Preferences *preferences = [[[SPAppDelegate sharedDelegate] simperium] preferencesObject];
    NSNumber *enabled = [preferences analytics_enabled];

    return [enabled boolValue] == false;
}

@end
