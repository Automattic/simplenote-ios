//
//  VSTheme+Extensions.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 9/17/15.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSTheme.h"


@interface VSTheme (Extensions)

- (CGFloat)floatForKey:(NSString *)rawKey contextView:(UIView *)view;

@end
