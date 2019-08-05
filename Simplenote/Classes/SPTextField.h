//
//  SPTextField.h
//  Simplenote
//
//  Created by Tom Witkin on 10/13/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPTextField : UITextField

@property (nonatomic, assign) UIEdgeInsets rightViewInsets;
@property (nonatomic, strong) UIColor *placeholdTextColor;

@end
