//
//  SPBorderedView.h
//  Simplenote
//
//  Created by Tom Witkin on 7/28/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPBorderedView : UIView


@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic) UIEdgeInsets borderInset;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic) CGFloat cornerRadius;

@property (nonatomic) BOOL showRightBorder;
@property (nonatomic) BOOL showLeftBorder;
@property (nonatomic) BOOL showTopBorder;
@property (nonatomic) BOOL showBottomBorder;

@end
