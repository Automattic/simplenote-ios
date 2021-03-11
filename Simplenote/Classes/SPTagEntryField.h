//
//  SPTagTextView.h
//  Simplenote
//
//  Created by Tom Witkin on 7/24/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPTextField.h"

@class SPTagEntryField;

@protocol SPTagEntryFieldDelegate <NSObject>

@optional
- (void)tagEntryFieldDidChange:(SPTagEntryField *)tagTextField;
@end


@interface SPTagEntryField : SPTextField

@property (nonatomic, weak) id<SPTagEntryFieldDelegate> tagDelegate;

@end
