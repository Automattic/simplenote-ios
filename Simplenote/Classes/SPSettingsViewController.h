#import <UIKit/UIKit.h>
#import "SPTableViewController.h"

@class SpinnerViewController;

@interface SPSettingsViewController : SPTableViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    
    //Preferences
    NSNumber *sortOrderPref;
    NSNumber *numPreviewLinesPref;
}

@property (strong, nonatomic) SpinnerViewController           *spinnerViewController;

@end

extern NSString *const SPAlphabeticalTagSortPref;
