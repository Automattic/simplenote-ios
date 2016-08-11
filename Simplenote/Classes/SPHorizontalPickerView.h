//
//  SPHorizontalPicker.h
//  Simplenote
//
//  Created by Tom Witkin on 7/29/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPHorizontalPickerViewCell.h"
@class MagnifierView;
@class SPHorizontalPickerGradientView;

@class SPHorizontalPickerView;
@protocol SPHorizontalPickerViewDelegate <NSObject>

@required

- (SPHorizontalPickerViewCell *)pickerView:(SPHorizontalPickerView *)pickerView viewForIndex:(NSInteger)index;
- (NSInteger)numberOfItemsInPickerView:(SPHorizontalPickerView *)pickerView;

@optional

- (void)pickerView:(SPHorizontalPickerView *)pickerView didSelectItemAtIndex:(NSInteger)index;
- (NSString *)titleForPickerView:(SPHorizontalPickerView *)pickerView;
- (CGFloat)heightForItemInPickerView:(SPHorizontalPickerView *)pickerView;
- (CGFloat)widthForItemInPickerView:(SPHorizontalPickerView *)pickerView;

@end

@interface SPHorizontalPickerView : UIView <UICollectionViewDataSource, UICollectionViewDelegate> {
    
    id<SPHorizontalPickerViewDelegate> delegate;

    UILabel *titleLabel;
    UICollectionView *itemCollectionView;
    
    MagnifierView *selectionMagnifierView;
    SPHorizontalPickerGradientView *leftGradientView;
    SPHorizontalPickerGradientView *rightGradientView;
    
    NSInteger selectedIndex;
    
}

@property (nonatomic, assign) id<SPHorizontalPickerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
          itemClass:(Class)itemClass
           delegate:(id<SPHorizontalPickerViewDelegate>)delegate;

- (id)dequeueReusableCellforIndex:(NSInteger)index;

- (void)reloadData;
- (void)setSelectedIndex:(NSInteger)index;
- (void)selectItemAtIndex:(NSInteger)index;



@end
