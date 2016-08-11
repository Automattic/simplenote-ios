//
//  TWSwitch.h
//  Podcasts
//
//  Created by Tom Witkin on 1/9/13.
//  Copyright (c) 2013 Tom Witkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPToggle : UIButton {
    
    BOOL isOn;
}

- (BOOL)isOn;
- (BOOL)on;
- (void)setOn:(BOOL)on;

@end
