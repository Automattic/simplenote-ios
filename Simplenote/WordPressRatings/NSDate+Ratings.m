// Sourced from https://github.com/wordpress-mobile/WordPress-Ratings-iOS/blob/8ba469e80214d1be29f3a8ca6776ecb04acdb416/WordPress-Ratings-iOS/NSDate%2BRatings.m
#import "NSDate+Ratings.h"

@implementation NSDate (Ratings)

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate = nil;
    NSDate *toDate = nil;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:nil forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:nil forDate:toDateTime];

    NSDateComponents *delta = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];

    return delta.day;
}

@end
