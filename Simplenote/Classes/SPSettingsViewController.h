#import <UIKit/UIKit.h>
#import "DTPinLockController.h"
#import "SPTableViewController.h"

@interface SPSettingsViewController : SPTableViewController <PinLockDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    
    //Preferences
    NSNumber *sortOrderPref;
    NSNumber *numPreviewLinesPref;
}

@end

extern NSString *const SPAlphabeticalTagSortPref;
