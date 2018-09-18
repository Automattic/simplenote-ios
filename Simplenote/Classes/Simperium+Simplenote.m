#import "Simperium+Simplenote.h"
#import "Simplenote-Swift.h"


@implementation Simperium (Simplenote)

- (Preferences *)preferencesObject
{
    SPBucket *bucket = [self bucketForName:NSStringFromClass([Preferences class])];
    NSString *key = [SPCredentials simperiumPreferencesObjectKey];
    Preferences *preferences = [bucket objectForKey:key];
    if (preferences != nil) {
        return preferences;
    }

    return [bucket insertNewObjectForKey:[SPCredentials simperiumPreferencesObjectKey]];
}

@end
