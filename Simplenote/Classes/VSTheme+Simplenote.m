//
//  VSTheme+Simplenote.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 12/22/14.
//  Copyright (c) 2014 Automattic. All rights reserved.
//

#import "VSTheme+Simplenote.h"


@implementation VSTheme (Simplenote)

- (BOOL)isDark
{
    return [self boolForKey:@"dark"];
}

@end
