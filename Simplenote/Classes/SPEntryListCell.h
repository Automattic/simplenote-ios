//
//  SPCollaboratorCell.h
//  Simplenote
//
//  Created by Tom Witkin on 7/27/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPEntryListCell : UITableViewCell {
    
    UILabel *primaryLabel;
    UILabel *secondaryLabel;
    UIImageView *checkmarkImageView;
}

- (void)setupWithPrimaryText:(NSString *)primaryText secondaryText:(NSString *)secondaryText checkmarked:(BOOL)checkmarked;

@end
