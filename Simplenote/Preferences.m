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
    if ([key isEqualToString:@"analytics_enabled"]) {
        [CrashLogging cacheOptOutSetting: !self.analytics_enabled.boolValue];
    }

    [super didChangeValueForKey:key];
}

@end
