//
//  SPHorizontalPickerGradientView.h
//  Simplenote
//
//  Created by Tom Witkin on 7/30/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	SPHorizontalPickerGradientViewDirectionRight,
    SPHorizontalPickerGradientViewDirectionLeft
} SPHorizontalPickerGradientViewDirection;

@interface SPHorizontalPickerGradientView : UIView {
    
    SPHorizontalPickerGradientViewDirection gradientDirection;
    CAGradientLayer *gradientLayer;
}

- (instancetype)initWithGradientViewDirection:(SPHorizontalPickerGradientViewDirection)direction;

@end
