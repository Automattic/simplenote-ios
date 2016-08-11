//
//  SPSidebarViewController.m
//  Simplenote
//
//  Created by Tom Witkin on 10/14/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPSidebarViewController.h"

@interface SPSidebarViewController ()

@end

@implementation SPSidebarViewController

- (BOOL)containerViewControllerShouldShowSidePanel:(SPSidebarContainerViewController *)container {
    
    return NO;
}

@end
