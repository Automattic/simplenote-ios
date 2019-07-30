//
//  SPBorderedTableView.m
//  Simplenote
//
//  Copyright © 2016 Automattic. All rights reserved.
//

#import "SPBorderedTableView.h"
#import <Foundation/Foundation.h>
#import "Simplenote-Swift.h"


@implementation SPBorderedTableView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftBorder = [CALayer layer];
        self.leftBorder.opacity = 0;
        [self applyTheme];
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

- (void)applyTheme {
    self.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];
    self.leftBorder.backgroundColor = [UIColor colorWithName:UIColorNameDividerColor].CGColor;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

#if XCODE11
    if (@available(iOS 13.0, *)) {
        if ([previousTraitCollection hasDifferentColorAppearanceComparedToTraitCollection:self.traitCollection] == false) {
            return;
        }

        [self applyTheme];
    }
#endif
}

@end
