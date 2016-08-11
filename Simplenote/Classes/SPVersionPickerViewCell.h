//
//  SPHistoryPickerViewCell.h
//  Simplenote
//
//  Created by Tom Witkin on 7/29/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPHorizontalPickerViewCell.h"

@interface SPVersionPickerViewCell : SPHorizontalPickerViewCell {
    
    BOOL activityIndicatorVisible;
}

- (void)setActivityIndicatorVisible:(BOOL)visible animated:(BOOL)animated;
- (void)setDateText:(NSString *)dateText timeText:(NSString *)timeText;

@end
