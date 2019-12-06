#import <Simperium/SPManagedObject.h>


@interface Preferences: SPManagedObject

@property (nullable, nonatomic, strong) NSArray<NSString *> *recent_searches;
@property (nullable, nonatomic, copy) NSNumber              *analytics_enabled;

@end
