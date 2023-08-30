#import <Foundation/Foundation.h>
#import "SPManagedObject.h"


@interface Preferences: SPManagedObject

@property (nullable, nonatomic, strong) NSArray<NSString *> *recent_searches;
@property (nullable, nonatomic,   copy) NSNumber            *analytics_enabled;

@property (nullable, nonatomic,   copy) NSDate              *subscription_date;
@property (nullable, nonatomic,   copy) NSString            *subscription_level;
@property (nullable, nonatomic,   copy) NSString            *subscription_platform;

@end
