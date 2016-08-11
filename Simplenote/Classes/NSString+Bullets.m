//
//  NSString+Bullets.m
//  Simplenote
//
//  Created by Tom Witkin on 8/25/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "NSString+Bullets.h"


#pragma mark ====================================================================================
#pragma mark Constants
#pragma mark ====================================================================================

static NSString *const SPNewLineString  = @"\n";
static NSString *const SPTabString      = @"\t";
static NSString *const SPSpaceString    = @" ";


#pragma mark ====================================================================================
#pragma mark NSString (Bullets)
#pragma mark ====================================================================================

@implementation NSString (Bullets)

+ (NSString *)spaceString
{
    return SPSpaceString;
}

+ (NSString *)tabString
{
    return SPTabString;
}

+ (NSString *)newLineString
{
    return SPNewLineString;
}

- (BOOL)isNewlineString
{
    return [self isEqualToString:SPNewLineString];
}

- (BOOL)isTabString
{
    return [self isEqualToString:SPTabString];
}

@end
