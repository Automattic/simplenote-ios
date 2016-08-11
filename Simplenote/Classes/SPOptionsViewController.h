//
//  SPOptionsViewController.h
//  Simplenote
//
//  Created by Tom Witkin on 7/22/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTPinLockController.h"
#import "SPTableViewController.h"

@interface SPOptionsViewController : SPTableViewController <PinLockDelegate> {
    
    //Preferences
    NSNumber *sortOrderPref;
    NSNumber *numPreviewLinesPref;
}

//Preferences
- (BOOL)condesedNoteListPref;

@end

NSString *const SPCondensedNoteListPref;
NSString *const SPCondensedNoteListPreferenceChangedNotification;
NSString *const SPAlphabeticalSortPref;
NSString *const SPAlphabeticalSortPreferenceChangedNotification;
