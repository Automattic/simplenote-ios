#import <UIKit/UIKit.h>
#import "SPTableViewController.h"

@interface SPSettingsViewController : SPTableViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    //Preferences
    NSNumber *sortOrderPref;
    NSNumber *numPreviewLinesPref;
}

@property (nonatomic, strong) UISwitch      *biometrySwitch;

@end

extern NSString *const SPAlphabeticalTagSortPref;
extern NSString *const SPSustainerAppIconName;
