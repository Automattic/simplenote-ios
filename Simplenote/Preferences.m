#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Preferences.h"
#import "Simplenote-Swift.h"


@implementation Preferences

@dynamic ghostData;
@dynamic simperiumKey;

@dynamic recent_searches;
@dynamic analytics_enabled;

- (void) didChangeValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"analytics_enabled"]) {
        [CrashLogging cacheOptOutSetting: !self.analytics_enabled.boolValue];
    }

    [super didChangeValueForKey:key];
}

@end
