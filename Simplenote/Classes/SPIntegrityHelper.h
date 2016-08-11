//
//  SPAppDelegate+Integrity.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/2/14.
//  Copyright (c) 2014 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>



@class Simperium;

#pragma mark ================================================================================
#pragma mark SPIntegrityHelper
#pragma mark ================================================================================

// TODO: Nuke this class after... one? two releases?

@interface SPIntegrityHelper : NSObject

+ (void)reloadInconsistentNotesIfNeeded:(Simperium *)simperium;

@end
