//
//  UITableView+Styling.m
//  Simplenote
//
//  Created by Tom Witkin on 8/23/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "UITableView+Styling.h"
#import "VSThemeManager.h"

@implementation UITableView (Styling)

- (void)applyDefaultGroupedStyling {
    
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    
    self.backgroundColor = [theme colorForKey:@"tableViewBackgroundColor"];
    self.separatorColor = [theme colorForKey:@"tableViewSeparatorColor"];
}

@end
