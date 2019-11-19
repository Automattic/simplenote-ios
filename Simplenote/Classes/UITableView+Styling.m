#import "UITableView+Styling.h"
#import "Simplenote-Swift.h"


@implementation UITableView (Styling)

- (void)applyDefaultGroupedStyling {
    self.backgroundColor = [UIColor colorWithName:UIColorNameTableViewBackgroundColor];
    self.separatorColor = [UIColor simplenoteDividerColor];
}

@end
