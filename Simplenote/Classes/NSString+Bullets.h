//
//  NSString+Bullets.h
//  Simplenote
//
//  Created by Tom Witkin on 8/25/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Bullets)

+ (NSString *)spaceString;
+ (NSString *)tabString;
+ (NSString *)newLineString;

- (BOOL)isNewlineString;
- (BOOL)isTabString;

@end
