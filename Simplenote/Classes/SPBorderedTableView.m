//
//  SPBorderedTableView.m
//  Simplenote
//
//  Copyright © 2016 Automattic. All rights reserved.
//

#import "SPBorderedTableView.h"
#import <Foundation/Foundation.h>

#import "VSThemeManager.h"
#import "VSTheme+Simplenote.h"

@implementation SPBorderedTableView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBorder = [CALayer layer];
        self.leftBorder.backgroundColor = [self.theme colorForKey:@"tableViewSeparatorColor"].CGColor;
        self.leftBorder.opacity = 0;
        [self.layer addSublayer:self.leftBorder];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.leftBorder.frame = CGRectMake(0, 0, 0.5, MAX(self.contentSize.height, self.bounds.size.height));
}

- (void)setBorderVisibile:(BOOL)isVisible {
    self.leftBorder.opacity = isVisible ? 1 : 0;
}

- (VSTheme *)theme {
    return [[VSThemeManager sharedManager] theme];
}

@end
