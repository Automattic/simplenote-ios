//
//  SPSideBySideView.h
//  Simplenote
//
//  Created by Tom Witkin on 7/30/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPSideBySideView : UIView {
    
    UIView *firstView;
    UIView *secondView;
    
}

- (id)initWithFirstView:(UIView *)firstView secondView:(UIView *)secondView;

@end
