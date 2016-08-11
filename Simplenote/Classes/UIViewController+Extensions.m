//
//  UIViewController+Extensions.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 9/17/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import "UIViewController+Extensions.h"
#import "UIDevice+Extensions.h"

@implementation UIViewController (Extensions)

- (BOOL)isViewHorizontallyCompact
{
    return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
}

- (BOOL)isViewVerticallyCompact
{
    return self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact;
}

@end
