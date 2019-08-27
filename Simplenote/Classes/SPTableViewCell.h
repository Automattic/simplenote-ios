//
//  SPCollectionViewCell.h
//  Simplenote
//
//  Created by Tom Witkin on 7/3/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Note;
@class SPTextView;

@interface SPTableViewCell : UITableViewCell 

@property (nonatomic, strong) UIImage *accessoryImage0;
@property (nonatomic, strong) UIImage *accessoryImage1;
@property (nonatomic, strong) UIColor *accessoryTintColor0;
@property (nonatomic, strong) UIColor *accessoryTintColor1;
@property (nonatomic, strong) SPTextView *previewView;

- (CGRect)listAnimationFrameForWidth:(CGFloat)width;
- (void)applyStyle;

@end
