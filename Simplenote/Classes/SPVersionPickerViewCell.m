//
//  SPHistoryPickerViewCell.m
//  Simplenote
//
//  Created by Tom Witkin on 7/29/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPVersionPickerViewCell.h"
#import "Simplenote-Swift.h"

@interface SPVersionPickerViewCell ()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation SPVersionPickerViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isAccessibilityElement = YES;
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.isAccessibilityElement = NO;
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.isAccessibilityElement = NO;
        
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        UIColor *textColor = [UIColor simplenoteTextColor];
        
        _dateLabel.font = font;
        _dateLabel.textColor = textColor;
        _timeLabel.font = font;
        _timeLabel.textColor = textColor;
        
        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_timeLabel];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        [self.contentView addSubview:_activityIndicator];
    
        activityIndicatorVisible = YES;
        [self setActivityIndicatorVisible:NO animated:NO];
        
    }
    return self;
}

- (void)layoutSubviews {
    
    CGFloat padding = 10;
    CGFloat timeLabelHeight = (_timeLabel.text.length > 0 ? _timeLabel.font.lineHeight : 0.0);
    CGFloat totalHeight = _dateLabel.font.lineHeight + timeLabelHeight;
    
    _dateLabel.frame = CGRectMake(padding,
                                  (self.bounds.size.height - totalHeight) / 2.0,
                                  self.bounds.size.width - 2 * padding,
                                  _dateLabel.font.lineHeight);
    _timeLabel.frame = CGRectMake(padding,
                                  _dateLabel.frame.origin.x + _dateLabel.frame.size.height,
                                  self.bounds.size.width - 2 * padding,
                                  timeLabelHeight);

    CGRect bounds = self.bounds;
    CGSize activitySize = _activityIndicator.frame.size;
    _activityIndicator.frame = CGRectMake((bounds.size.width - activitySize.width) / 2.0,
                                          (bounds.size.height - activitySize.height) / 2.0,
                                          activitySize.width,
                                          activitySize.height);
    
}

- (void)setActivityIndicatorVisible:(BOOL)visible animated:(BOOL)animated {
    
    if (activityIndicatorVisible ==  visible)
        return;
    
    if (visible)
        [_activityIndicator startAnimating];
    else
        [_activityIndicator stopAnimating];
    
    activityIndicatorVisible = visible;
    
    [UIView animateWithDuration:animated ? 0.3 : 0.0
                     animations:^{
                         
                         self->_activityIndicator.alpha = visible ? 1.0 : 0.0;
                         self->_timeLabel.alpha = visible ? 0.0 : 1.0;
                         self->_dateLabel.alpha = visible ? 0.0 : 1.0;
                         
                     }];
}

- (void)setDateText:(NSString *)dateText timeText:(NSString *)timeText {
    
    _dateLabel.text = dateText;
    _timeLabel.text = timeText;
    
    [self setNeedsLayout];
}

@end
