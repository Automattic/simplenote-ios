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

@property (nonatomic, strong) UIImage *accessoryImage;
@property (nonatomic, strong) UIColor *accessoryTintColor;
@property (nonatomic, strong) SPTextView *previewView;

- (CGRect)previewViewRectForWidth:(CGFloat)width fast:(BOOL)fast;
- (void)applyStyle;

@end
