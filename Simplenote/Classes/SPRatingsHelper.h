//
//  SPRatingsHelper.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/19/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import "WPRatingsHelper.h"

@interface SPRatingsHelper : WPRatingsHelper

- (void)reloadSettings;
- (BOOL)shouldPromptForAppReview;

@end
