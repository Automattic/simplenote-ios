//
//  SPHorizontalPicker.m
//  Simplenote
//
//  Created by Tom Witkin on 7/29/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPHorizontalPickerView.h"
#import "VSThemeManager.h"
#import "SPHorizontalPickerGradientView.h"
#import "Simplenote-Swift.h"

static CGSize PickerDefaultSize = {88.0, 88.0};
static NSString *itemIdentifier = @"horizontalPickerItem";

@interface SPHorizontalPickerView ()

@property (nonatomic) CGFloat fixedHeight;
@end

@implementation SPHorizontalPickerView

- (id<SPHorizontalPickerViewDelegate>)delegate {
    
    return delegate;
}
- (void)setDelegate:(id<SPHorizontalPickerViewDelegate>)newDelegate
{
    delegate = newDelegate;
}

// the view has a fixed height based on item size
- (void)setFrame:(CGRect)frame {
    
    if (!(_fixedHeight > 0)) {
        
        CGFloat titleHeight = 0.0;
        CGFloat verticalPadding = [self.theme floatForKey:@"horizontalPickerVerticalPadding"];
        if ([delegate respondsToSelector:@selector(titleForPickerView:)])
            titleHeight = [self.theme floatForKey:@"horizontalPickerTitleHeight"] + verticalPadding;
        
        _fixedHeight = self.itemHeight + verticalPadding + titleHeight;
    }
    
    
    frame.size.height = _fixedHeight;
    [super setFrame:frame];
        
    
}

- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

- (id)initWithFrame:(CGRect)frame
          itemClass:(__unsafe_unretained Class)itemClass
           delegate:(id<SPHorizontalPickerViewDelegate>)d
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setDelegate:d];
        
        _fixedHeight = 0.0;
        [self setFrame:frame];
        
        CGFloat verticalPadding = [self.theme floatForKey:@"horizontalPickerVerticalPadding"];
        CGFloat horizontalPadding = [self.theme floatForKey:@"horizontalPickerHorizontalPadding"];
        
        // title label
        titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(horizontalPadding,
                                      verticalPadding,
                                      frame.size.width - 2 * horizontalPadding,
                                      [self.theme floatForKey:@"horizontalPickerTitleHeight"]);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        titleLabel.textColor = [UIColor simplenoteTitleColor];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:titleLabel];
        
        if ([delegate respondsToSelector:@selector(titleForPickerView:)])
            titleLabel.text = [delegate titleForPickerView:self].uppercaseString;
        
        // create collectionView
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = horizontalPadding;
        flowLayout.itemSize = CGSizeMake(self.itemWidth, self.itemHeight);
        CGFloat insetAmount = (self.bounds.size.width - self.itemWidth) / 2.0 + 1.5 * horizontalPadding;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount);
        CGFloat collectionViewYOrigin = titleLabel.frame.origin.y + titleLabel.frame.size.height;
        itemCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,
                                                                                collectionViewYOrigin,
                                                                                self.bounds.size.width,
                                                                                self.bounds.size.height - collectionViewYOrigin - verticalPadding)
                                                collectionViewLayout:flowLayout];
        itemCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:itemCollectionView];
        
        [itemCollectionView registerClass:itemClass
               forCellWithReuseIdentifier:itemIdentifier];
        itemCollectionView.delegate = self;
        itemCollectionView.dataSource = self;
//        itemCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        itemCollectionView.showsVerticalScrollIndicator = NO;
        itemCollectionView.showsHorizontalScrollIndicator = NO;
        itemCollectionView.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [UIColor simplenoteTableViewBackgroundColor];

        // add gradients
        leftGradientView = [[SPHorizontalPickerGradientView alloc] initWithGradientViewDirection:SPHorizontalPickerGradientViewDirectionLeft];
        [self addSubview:leftGradientView];
        
        rightGradientView = [[SPHorizontalPickerGradientView alloc] initWithGradientViewDirection:SPHorizontalPickerGradientViewDirectionRight];
        [self addSubview:rightGradientView];
        
        selectedIndex = 0;
        
    }
    return self;
}



- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGFloat gradientLeftPosition = itemCollectionView.center.x - (self.itemWidth / 2);
    CGFloat gradientRightPosition = itemCollectionView.center.x + (self.itemWidth / 2);
    leftGradientView.frame = CGRectMake(0,
                                        itemCollectionView.frame.origin.y,
                                        gradientLeftPosition,
                                        itemCollectionView.frame.size.height);
    rightGradientView.frame = CGRectMake(gradientRightPosition,
                                         itemCollectionView.frame.origin.y,
                                         self.bounds.size.width - gradientRightPosition,
                                         itemCollectionView.frame.size.height);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    self.alpha = 0.0;
    
}

- (void)didMoveToSuperview {
    
    // this delay is needed in order to select the correct item
    double delayInSeconds = 0.15;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self->itemCollectionView setContentOffset:[self scrollOffsetForIndex:self->selectedIndex]];
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.alpha = 1.0;
                         }];
        
    });
    
}


- (id)dequeueReusableCellforIndex:(NSInteger)index {
    
    return [itemCollectionView dequeueReusableCellWithReuseIdentifier:itemIdentifier
                                                  forIndexPath:[NSIndexPath indexPathForItem:index
                                                                                   inSection:0]];
}

- (CGFloat)itemWidth {
    
    CGFloat width = 0.0;
    if ([delegate respondsToSelector:@selector(widthForItemInPickerView:)])
        width = [delegate widthForItemInPickerView:self];
    if (!(width > 0)) width = PickerDefaultSize.width;
    
    return width;
    
}

- (CGFloat)itemHeight {
    
    CGFloat height = 0.0;
    if ([delegate respondsToSelector:@selector(heightForItemInPickerView:)])
        height = [delegate heightForItemInPickerView:self];
    if (!(height > 0)) height = PickerDefaultSize.height;
    
    return height;
    
}

#pragma mark UIScrollViewDelegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
        [self selectItemAtPoint:scrollView.contentOffset sendDelegateCallback:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!decelerate)
        [self selectItemAtPoint:scrollView.contentOffset sendDelegateCallback:YES];

}

- (void)selectItemAtPoint:(CGPoint)point sendDelegateCallback:(BOOL)send {
    
    // the scrollview must stop perfectly aligned with the center of
    CGFloat itemWidth = self.itemWidth;
    CGFloat spacing = [(UICollectionViewFlowLayout *)itemCollectionView.collectionViewLayout minimumLineSpacing];
    
    NSInteger index = point.x / (itemWidth + spacing);
    NSInteger remainder = point.x - index * (itemWidth + spacing);
    
    if (remainder > itemWidth / 2.0)
        index ++;
    
    index = MIN(index, [delegate numberOfItemsInPickerView:self] - 1);
        
    [self selectItemAtIndex:index sendDelegateCallback:send animated:YES];
}

- (void)setSelectedIndex:(NSInteger)index {
    selectedIndex = index;
}

- (void)selectItemAtIndex:(NSInteger)index {
    
    [self selectItemAtIndex:index sendDelegateCallback:NO animated:YES];

}

- (void)selectItemAtIndex:(NSInteger)index sendDelegateCallback:(BOOL)send animated:(BOOL)animated {
    
    
    [itemCollectionView setContentOffset:[self scrollOffsetForIndex:index]
                                animated:animated];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // only dend delegate method if the view isn't scrolling
        // and have a delay in case the user starts scrolling again immediately
        if (send && !self->itemCollectionView.isDecelerating && !self->itemCollectionView.isDragging &&
            
            [self->delegate respondsToSelector:@selector(pickerView:didSelectItemAtIndex:)])
            [self->delegate pickerView:self didSelectItemAtIndex:index];
    });
    
    selectedIndex = index;
}

- (CGPoint)scrollOffsetForIndex:(NSInteger)index {
    
    CGFloat xOffset;
        
    // find appropriate contentOffset for item at index
    if ([itemCollectionView numberOfItemsInSection:0] > index && index >= 0) {
        
        CGRect itemRect = [[itemCollectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]] frame];
        
        xOffset = itemRect.origin.x - [(UICollectionViewFlowLayout *)itemCollectionView.collectionViewLayout sectionInset].left;
    } else
        xOffset = itemCollectionView.contentOffset.x;

    return CGPointMake(xOffset, 0);
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [delegate numberOfItemsInPickerView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [delegate pickerView:self viewForIndex:indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // must account for the section insets
    [self selectItemAtIndex:indexPath.row sendDelegateCallback:YES animated:YES];
    
}

- (void)reloadData {
    [itemCollectionView reloadData];
}

@end
