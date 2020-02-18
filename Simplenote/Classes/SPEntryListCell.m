//
//  SPCollaboratorCell.m
//  Simplenote
//
//  Created by Tom Witkin on 7/27/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPEntryListCell.h"
#import "VSThemeManager.h"
#import "Simplenote-Swift.h"



@implementation SPEntryListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.backgroundColor = [UIColor simplenoteTableViewCellBackgroundColor];
        
        primaryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        primaryLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        primaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        primaryLabel.textColor = [UIColor simplenoteTextColor];
        [self.contentView addSubview:primaryLabel];
        
        secondaryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        secondaryLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        secondaryLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        secondaryLabel.textColor = [UIColor simplenoteTitleColor];
        [self.contentView addSubview:secondaryLabel];
        
        UIImage *checkedImage = [UIImage imageWithName:UIImageNameCheckmarkChecked];
        UIImage *uncheckedImage = [UIImage imageWithName:UIImageNameCheckmarkUnchecked];

        checkmarkImageView = [[UIImageView alloc] initWithImage:uncheckedImage
                                               highlightedImage:checkedImage];
        checkmarkImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [checkmarkImageView setHighlighted:NO];
        
        [checkmarkImageView sizeToFit];
        [self.contentView addSubview:checkmarkImageView];
        
        checkmarkImageView.hidden = YES;
        
    }
    return self;
}

- (void)layoutSubviews {
    
    // vertically center primary label if secondary label has no text
    
    CGFloat primaryLabelHeight = primaryLabel.font.lineHeight;
    CGFloat secondaryLabelHeight = secondaryLabel.text.length > 0 ? secondaryLabel.font.lineHeight : 0;
    CGFloat cellHeight = self.bounds.size.height;
    CGFloat padding = [self.theme floatForKey:@"collaboratorCellSidePadding"];
    
    
    checkmarkImageView.frame = CGRectMake(self.bounds.size.width - checkmarkImageView.bounds.size.width - padding,
                                          (cellHeight - checkmarkImageView.bounds.size.height) / 2.0,
                                          checkmarkImageView.frame.size.width,
                                          checkmarkImageView.frame.size.height);
    
    primaryLabel.frame = CGRectMake(padding,
                                    (cellHeight - (primaryLabelHeight + secondaryLabelHeight)) / 2.0,
                                    checkmarkImageView.frame.origin.x - 2 * padding,
                                    primaryLabelHeight);
    
    secondaryLabel.frame = CGRectMake(padding,
                                    primaryLabelHeight + primaryLabel.frame.origin.y,
                                    checkmarkImageView.frame.origin.x - 2 * padding,
                                    secondaryLabelHeight);
    
}

- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithPrimaryText:(NSString *)primaryText secondaryText:(NSString *)secondaryText checkmarked:(BOOL)checkmarked {
    
    primaryLabel.text = primaryText;
    secondaryLabel.text = secondaryText;
    checkmarkImageView.highlighted = checkmarked;
    
    [self setNeedsLayout];
}


@end
