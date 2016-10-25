//
//  SPBorderedTableView.h
//  Simplenote
//
//  Copyright © 2016 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPBorderedTableView : UITableView

@property CALayer *leftBorder;

- (void)setBorderVisibile:(BOOL)isVisible;

@end
