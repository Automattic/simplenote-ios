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

@interface SPOptionsViewController : SPTableViewController <PinLockDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    
    //Preferences
    NSNumber *sortOrderPref;
    NSNumber *numPreviewLinesPref;
}

//Preferences
- (BOOL)condesedNoteListPref;

@end

extern NSString *const SPCondensedNoteListPref;
extern NSString *const SPCondensedNoteListPreferenceChangedNotification;
extern NSString *const SPAlphabeticalSortPref;
extern NSString *const SPAlphabeticalSortPreferenceChangedNotification;
extern NSString *const SPAlphabeticalTagSortPref;
extern NSString *const SPAlphabeticalTagSortPreferenceChangedNotification;
