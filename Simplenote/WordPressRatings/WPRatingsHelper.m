// Sourced from https://github.com/wordpress-mobile/WordPress-Ratings-iOS/blob/8ba469e80214d1be29f3a8ca6776ecb04acdb416/WordPress-Ratings-iOS/WPRatingsHelper.m
#import "WPRatingsHelper.h"
#import "NSDate+Ratings.h"

#pragma mark ================================================================================
#pragma mark Constants
#pragma mark ================================================================================

#pragma mark - UserDefault Keys

static NSString *const WPRatingsCurrentVersion                    = @"WPRatingsCurrentVersion";
static NSString *const WPRatingsSignificantEventCount             = @"WPRatingsSignificantEventCount";
static NSString *const WPRatingsUseCount                          = @"WPRatingsUseCount";
static NSString *const WPRatingsNumberOfVersionsSkippedPrompting  = @"WPRatingsNumberOfVersionsSkippedPrompting";
static NSString *const WPRatingsNumberOfVersionsToSkipPrompting   = @"WPRatingsNumberOfVersionsToSkipPrompting";
static NSString *const WPRatingsSkipRatingCurrentVersion          = @"WPRatingsSkipRatingCurrentVersion";
static NSString *const WPRatingsRatedCurrentVersion               = @"WPRatingsRatedCurrentVersion";
static NSString *const WPRatingsDeclinedToRateCurrentVersion      = @"WPRatingsDeclinedToRateCurrentVersion";
static NSString *const WPRatingsGaveFeedbackForCurrentVersion     = @"WPRatingsGaveFeedbackForCurrentVersion";
static NSString *const WPRatingsDislikedCurrentVersion            = @"WPRatingsDislikedCurrentVersion";
static NSString *const WPRatingsLikedCurrentVersion               = @"WPRatingsLikedCurrentVersion";
static NSString *const WPRatingsUserLikeCount                     = @"WPRatingsUserLikeCount";
static NSString *const WPRatingsUserDislikeCount                  = @"WPRatingsUserDislikeCount";
static NSString *const WPRatingsLastReviewVersion                 = @"WPRatingsLastReviewVersion";
static NSString *const WPRatingsLastReviewDate                    = @"WPRatingsLastReviewDate";

#pragma mark - Default Settings

static BOOL const WPRatingsDefaultRatingsDisabled                 = false;
static NSInteger const WPRatingsDefaultMinimumEvents              = 5;
static NSInteger const WPRatingsDefaultMinimumIntervalDays        = 90;
static NSInteger const WPRatingsDefaultLikeSkipVersions           = 1;
static NSInteger const WPRatingsDefaultDefaultDeclineSkipVersions = 2;
static NSInteger const WPRatingsDefaultDislikeSkipVersions        = 2;


#pragma mark ================================================================================
#pragma mark WPRatingsHelper
#pragma mark ================================================================================

@implementation WPRatingsHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ratingsDisabled        = WPRatingsDefaultRatingsDisabled;
        _significantEventsCount = WPRatingsDefaultMinimumEvents;
        _minimumIntervalDays    = WPRatingsDefaultMinimumIntervalDays;
        _likeSkipVersions       = WPRatingsDefaultLikeSkipVersions;
        _declineSkipVersions    = WPRatingsDefaultDefaultDeclineSkipVersions;
        _dislikeSkipVersions    = WPRatingsDefaultDislikeSkipVersions;
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static WPRatingsHelper *_sharedAppRatingUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAppRatingUtility = [self new];
    });

    return _sharedAppRatingUtility;
}

- (void)initializeForVersion:(NSString *)version
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *trackingVersion = [userDefaults stringForKey:WPRatingsCurrentVersion];
    if (trackingVersion == nil)
    {
        trackingVersion = version;
        [userDefaults setObject:version forKey:WPRatingsCurrentVersion];
    }

    if ([trackingVersion isEqualToString:version])
    {
        // Increment the use count
        NSInteger useCount = [userDefaults integerForKey:WPRatingsUseCount];
        useCount++;
        [userDefaults setInteger:useCount forKey:WPRatingsUseCount];
    }
    else
    {
        // Restarting tracking for new version of app
        BOOL interactedWithReviewPromptInPreviousVersion = [self interactedWithReviewPrompt];
        BOOL skippedRatingPreviousVersion = [self skipRatingCurrentVersion];

        [userDefaults setObject:version forKey:WPRatingsCurrentVersion];
        [userDefaults setInteger:0 forKey:WPRatingsSignificantEventCount];
        [userDefaults setBool:NO forKey:WPRatingsRatedCurrentVersion];
        [userDefaults setBool:NO forKey:WPRatingsDeclinedToRateCurrentVersion];
        [userDefaults setBool:NO forKey:WPRatingsGaveFeedbackForCurrentVersion];
        [userDefaults setBool:NO forKey:WPRatingsDislikedCurrentVersion];
        [userDefaults setBool:NO forKey:WPRatingsLikedCurrentVersion];
        [userDefaults setBool:NO forKey:WPRatingsSkipRatingCurrentVersion];

        if (interactedWithReviewPromptInPreviousVersion || skippedRatingPreviousVersion) {
            NSInteger numberOfVersionsSkippedPrompting = [userDefaults integerForKey:WPRatingsNumberOfVersionsSkippedPrompting];
            NSInteger numberOfVersionsToSkipPrompting = [userDefaults integerForKey:WPRatingsNumberOfVersionsToSkipPrompting];

            if (numberOfVersionsToSkipPrompting > 0) {
                if (numberOfVersionsSkippedPrompting < numberOfVersionsToSkipPrompting) {
                    // We haven't skipped enough versions, skip this one
                    numberOfVersionsSkippedPrompting++;
                    [userDefaults setInteger:numberOfVersionsSkippedPrompting forKey:WPRatingsNumberOfVersionsSkippedPrompting];
                    [userDefaults setBool:YES forKey:WPRatingsSkipRatingCurrentVersion];
                } else {
                    // We have skipped enough, reset data
                    [userDefaults setInteger:0 forKey:WPRatingsNumberOfVersionsSkippedPrompting];
                    [userDefaults setInteger:0 forKey:WPRatingsNumberOfVersionsToSkipPrompting];
                }
            }
        }
    }
}

- (void)incrementSignificantEvent
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger numberOfSignificantEvents = [userDefaults integerForKey:WPRatingsSignificantEventCount];
    numberOfSignificantEvents++;
    [userDefaults setInteger:numberOfSignificantEvents forKey:WPRatingsSignificantEventCount];
    [userDefaults synchronize];
}

- (void)declinedToRateCurrentVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:WPRatingsDeclinedToRateCurrentVersion];
    [userDefaults setInteger:self.declineSkipVersions forKey:WPRatingsNumberOfVersionsToSkipPrompting];
    [userDefaults synchronize];
}

- (void)gaveFeedbackForCurrentVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:WPRatingsGaveFeedbackForCurrentVersion];
    [userDefaults synchronize];
}

- (void)ratedCurrentVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:WPRatingsRatedCurrentVersion];
    [userDefaults synchronize];
}

- (void)dislikedCurrentVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger userDislikeCount = [userDefaults integerForKey:WPRatingsUserDislikeCount];
    userDislikeCount++;
    [userDefaults setInteger:userDislikeCount forKey:WPRatingsUserDislikeCount];
    [userDefaults setBool:YES forKey:WPRatingsDislikedCurrentVersion];
    [userDefaults setInteger:self.dislikeSkipVersions forKey:WPRatingsNumberOfVersionsToSkipPrompting];
    [userDefaults synchronize];
}

- (void)likedCurrentVersion
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSUInteger userLikeCount = [userDefaults integerForKey:WPRatingsUserLikeCount];
    userLikeCount++;
    [userDefaults setInteger:userLikeCount forKey:WPRatingsUserLikeCount];
    [userDefaults setBool:YES forKey:WPRatingsLikedCurrentVersion];
    [userDefaults setInteger:self.likeSkipVersions forKey:WPRatingsNumberOfVersionsToSkipPrompting];
    [userDefaults synchronize];
}


- (BOOL)shouldPromptForAppReview
{
    if (self.interactedWithReviewPrompt || self.skipRatingCurrentVersion || self.ratingsDisabled || !self.enoughDaysElapsed) {
        return NO;
    }

    BOOL shouldPrompt = self.eventCount >= self.significantEventsCount;
    if (shouldPrompt) {
        [self markAsPrompted];
    }

    return shouldPrompt;
}

- (BOOL)hasUserEverLikedApp
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:WPRatingsUserLikeCount] > 0;
}

- (BOOL)hasUserEverDislikedApp
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:WPRatingsUserDislikeCount] > 0;
}


#pragma mark - Private Helpers

- (BOOL)interactedWithReviewPrompt
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return  [userDefaults boolForKey:WPRatingsRatedCurrentVersion] ||
    [userDefaults boolForKey:WPRatingsDeclinedToRateCurrentVersion] ||
    [userDefaults boolForKey:WPRatingsGaveFeedbackForCurrentVersion] ||
    [userDefaults boolForKey:WPRatingsLikedCurrentVersion]||
    [userDefaults boolForKey:WPRatingsDislikedCurrentVersion];
}

- (BOOL)skipRatingCurrentVersion
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:WPRatingsSkipRatingCurrentVersion];
}

- (NSUInteger)eventCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:WPRatingsSignificantEventCount];
}


#pragma mark - Date Helpers

- (BOOL)enoughDaysElapsed
{
    NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
    NSString *currentVersion        = [defaults stringForKey:WPRatingsCurrentVersion];
    NSString *lastVersionReviewed   = [defaults stringForKey:WPRatingsLastReviewVersion];

    // Don't proceed if: the app was never reviewed OR we've already prompted for this version
    if (lastVersionReviewed == nil || [currentVersion isEqualToString:lastVersionReviewed]) {
        return YES;
    }

    NSDate *lastReviewDate          = [defaults objectForKey:WPRatingsLastReviewDate];
    NSInteger delta                 = [NSDate daysBetweenDate:lastReviewDate andDate:[NSDate date]];

    return delta >= self.minimumIntervalDays;
}

- (void)markAsPrompted
{
    NSUserDefaults *defaults        = [NSUserDefaults standardUserDefaults];
    NSString *currentVersion        = [defaults stringForKey:WPRatingsCurrentVersion];
    NSString *lastVersionReviewed   = [defaults stringForKey:WPRatingsLastReviewVersion];

    // Mark just once per version
    if ([currentVersion isEqualToString:lastVersionReviewed]) {
        return;
    }

    [defaults setValue:currentVersion forKey:WPRatingsLastReviewVersion];
    [defaults setValue:[NSDate date] forKey:WPRatingsLastReviewDate];
    [defaults synchronize];
}

@end
