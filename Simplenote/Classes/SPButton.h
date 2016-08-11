//
//  SPButton.h
//  Simplenote
//
//  Created by Tom Witkin on 7/16/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPButton : UIButton {
    
    UIColor *backgroundColor;
    UIColor *backgroundHighlightColor;
    
}

@property (nonatomic, strong) UIColor *backgroundHighlightColor;

@end
