//
//  SPBorderedTableView.h
//  Simplenote
//
//  Copyright © 2016 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPBorderedTableView : UITableView

@property (nonatomic, strong) CALayer *leftBorder;

- (void)setBorderVisibile:(BOOL)isVisible;
- (void)applyTheme;

@end
