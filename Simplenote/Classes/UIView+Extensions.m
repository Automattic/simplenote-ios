//
//  UIView+Extensions.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 9/17/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import "UIView+Extensions.h"
#import "UIDevice+Extensions.h"

@implementation UIView (Extensions)

- (BOOL)isHorizontallyCompact
{
    // iOS <= 8:
    // We'll just consider 'Compact' all of non iPad Devices
    if ([self respondsToSelector:@selector(traitCollection)] == false) {
        return [UIDevice isPad] == false;
    }
    
    return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
}

@end
