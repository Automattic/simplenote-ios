//
//  SPEmptyListView.h
//  Simplenote
//
//  Created by Tom Witkin on 8/5/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPEmptyListView : UIView {
    
    BOOL hideImageView;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;

- (id)initWithImage:(UIImage *)image withText:(NSString *)text;
- (void)setText:(NSString *)text;
- (void)setImage:(UIImage *)image;
- (void)setColor:(UIColor *)color;

- (void)hideImageView:(BOOL)hide;

@end
