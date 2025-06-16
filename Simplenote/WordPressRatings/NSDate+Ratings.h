// Sourced from https://github.com/wordpress-mobile/WordPress-Ratings-iOS/blob/8ba469e80214d1be29f3a8ca6776ecb04acdb416/WordPress-Ratings-iOS/NSDate%2BRatings.h
#import <Foundation/Foundation.h>

@interface NSDate (Ratings)

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;

@end
