#import <UIKit/UIKit.h>
#import "SPTableViewController.h"
#import "SPModalActivityIndicator.h"

@class PasskeyAuthenticator;

@interface SPSettingsViewController : SPTableViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    //Preferences
    NSNumber *sortOrderPref;
    NSNumber *numPreviewLinesPref;
}

@end

extern NSString * const SPAlphabeticalTagSortPref;
extern NSString * const SPSustainerAppIconName;
