//
//  SPCollaboratorCompletionCell.m
//  Simplenote
//
//  Created by Tom Witkin on 7/27/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPEntryListAutoCompleteCell.h"

@implementation SPEntryListAutoCompleteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        primaryLabel.font = secondaryLabel.font;
        checkmarkImageView.hidden = YES;
    }
    return self;
}


@end
