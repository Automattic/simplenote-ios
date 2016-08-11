//
//  SPRatingsHelper.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/19/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import "SPRatingsHelper.h"
#import "SPAppDelegate.h"
#import "SPConstants.h"
#import "Settings.h"
#import "Simplenote-Swift.h"


@implementation SPRatingsHelper

- (void)reloadSettings
{
    Simperium *simperium = [[SPAppDelegate sharedDelegate] simperium];
    SPBucket *bucket = [simperium bucketForName:NSStringFromClass([Settings class])];
    
    Settings *settings = [bucket objectForKey:[SPCredentials simperiumSettingsObjectKey]];
    if (!settings) {
        return;
    }
    
    SPRatingsHelper *ratings = [SPRatingsHelper sharedInstance];
    
    ratings.ratingsDisabled = settings.ratings_disabled.boolValue;
    ratings.significantEventsCount = settings.minimum_events.integerValue;
    ratings.minimumIntervalDays = settings.minimum_interval_days.integerValue;
    
    ratings.likeSkipVersions = settings.like_skip_versions.integerValue;
    ratings.declineSkipVersions = settings.decline_skip_versions.integerValue;
    ratings.dislikeSkipVersions = settings.dislike_skip_versions.integerValue;
}

- (BOOL)shouldPromptForAppReview
{
    Simperium *simperium = [[SPAppDelegate sharedDelegate] simperium];
    
    return super.shouldPromptForAppReview && simperium.user.authenticated;
}

@end
