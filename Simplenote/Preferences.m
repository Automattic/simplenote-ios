#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Preferences.h"
#import "Simplenote-Swift.h"


@implementation Preferences

@dynamic ghostData;
@dynamic simperiumKey;

@dynamic recent_searches;
@dynamic analytics_enabled;

@dynamic subscription_date;
@dynamic subscription_level;
@dynamic subscription_platform;


- (void) didChangeValueForKey:(NSString *)key
{
    NSString *analyticsKey = NSStringFromSelector(@selector((analytics_enabled)));
    if ([key isEqualToString:analyticsKey]) {
        [CrashLogging cacheOptOutSetting: !self.analytics_enabled.boolValue];
    }

    NSString *subscriptionKey = NSStringFromSelector(@selector((subscription_level)));
    if ([key isEqualToString:subscriptionKey]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SPSubscriptionStatusDidChangeNotification object:nil];
    }

    [super didChangeValueForKey:key];
}

@end
