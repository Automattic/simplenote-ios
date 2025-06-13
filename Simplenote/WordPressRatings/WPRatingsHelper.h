// Sourced from https://github.com/wordpress-mobile/WordPress-Ratings-iOS/blob/8ba469e80214d1be29f3a8ca6776ecb04acdb416/WordPress-Ratings-iOS/WPRatingsHelper.h
#import <Foundation/Foundation.h>

/**
 This class will help track whether or not a user should be prompted for an app review.
 -   Appirater:          https://github.com/arashpayan/appirater
 -   AppRatingUtility:   https://github.com/wordpress-mobile/WordPress-iOS/blob/develop/WordPress/Classes/Utility/Ratings/AppRatingUtility.m
 */

@interface WPRatingsHelper : NSObject

/**
 *  Indicates the number of Significant events are required when calling `shouldPromptForAppReview`.
 */
@property (nonatomic, assign) NSUInteger significantEventsCount;

/**
 *  Indicates minimum number of days that must elapse before showing the Reminder again.
 */
@property (nonatomic, assign) NSUInteger minimumIntervalDays;

/**
 *  Indicates the number App Versions to skip when the user likes the app.
 */
@property (nonatomic, assign) NSUInteger likeSkipVersions;

/**
 *  Indicates the number App Versions to skip when the user declines to rate the app.
 */
@property (nonatomic, assign) NSUInteger declineSkipVersions;

/**
 *  Indicates the number App Versions to skip when the user dislikes the app.
 */
@property (nonatomic, assign) NSUInteger dislikeSkipVersions;

/**
 *  Allows the user to entirely disable the Ratings Reminder.
 */
@property (nonatomic, assign) BOOL ratingsDisabled;


/**
 *  Returns the shared AppRatings Instance
 */
+ (instancetype)sharedInstance;

/**
 *  This should be called with the current App Version so as to setup internal tracking.
 *
 *  @param version version number of the app, e.g. CFBundleShortVersionString
 */
- (void)initializeForVersion:(NSString *)version;

/**
 *  Increments significant events
 */
- (void)incrementSignificantEvent;

/**
 *  Indicates that the user didn't want to review the app or leave feedback for this version.
 */
- (void)declinedToRateCurrentVersion;

/**
 *  Indicates that the user decided to give feedback for this version.
 */
- (void)gaveFeedbackForCurrentVersion;

/**
 *  Indicates the the use rated the current version of the app.
 */
- (void)ratedCurrentVersion;

/**
 *  Indicates that the user didn't like the current version of the app.
 */
- (void)dislikedCurrentVersion;

/**
 *  Indicates the user did like the current version of the app.
 */
- (void)likedCurrentVersion;

/**
 *  Checks if the user should be prompted for an app review based on `significantEventsCount` and also
 *  if the user hasn't been configured to skip being prompted for this release.
 *  Note that this method will check to see if app review prompts on a global basis have been shut off.
 *
 *  @return true when the user has performed enough significant events and isn't configured to skip being prompted for this release.
 */
- (BOOL)shouldPromptForAppReview;

/**
 *  Checks if the user has ever indicated that they like the app.
 *
 *  @return true if the user has ever indicated they like the app.
 */
- (BOOL)hasUserEverLikedApp;

/**
 *  Checks if the user has ever indicated they dislike the app.
 *
 *  @return true if the user has ever indicated they don't like the app.
 */
- (BOOL)hasUserEverDislikedApp;

@end
