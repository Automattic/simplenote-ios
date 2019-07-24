//
//  UITableView+Styling.m
//  Simplenote
//
//  Created by Tom Witkin on 8/23/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "UITableView+Styling.h"
#import "Simplenote-Swift.h"


@implementation UITableView (Styling)

- (void)applyDefaultGroupedStyling {
    self.backgroundColor = [UIColor colorWithName:UIColorNameTableViewBackgroundColor];
    self.separatorColor = [UIColor colorWithName:UIColorNameTableViewSeparatorColor];
}

@end
