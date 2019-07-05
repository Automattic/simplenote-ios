//
//  VSTheme+Extensions.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 9/17/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import "VSTheme+Extensions.h"
#import "UIDevice+Extensions.h"
#import "Simplenote-Swift.h"

@implementation VSTheme (Extensions)

- (CGFloat)floatForKey:(NSString *)rawKey contextView:(UIView *)contextView
{
    NSString *patchedKey = [self patchKey:rawKey forTraitsInView:contextView];
    return [self floatForKey:patchedKey];
}

- (NSString *)patchKey:(NSString *)key forTraitsInView:(UIView *)view
{
    if ([UIDevice isPad] && !view.isHorizontallyCompact) {
        return [key stringByAppendingString:@"~regular"];
    }
    
    return key;
}

@end
