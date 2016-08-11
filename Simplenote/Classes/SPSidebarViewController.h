//
//  SPSidebarViewController.h
//  Simplenote
//
//  Created by Tom Witkin on 10/14/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPSidebarContainerViewController.h"

@interface SPSidebarViewController : UIViewController <SPContainerSidePanelViewDelegate>

@property (nonatomic, strong) SPSidebarContainerViewController *containerViewController;


@end
