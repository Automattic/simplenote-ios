#import <UIKit/UIKit.h>
#import "SPTableViewController.h"

@class PasskeyAuthenticator;

@interface SPSettingsViewController : SPTableViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    //Preferences
    NSNumber *sortOrderPref;
    NSNumber *numPreviewLinesPref;
}

@property (nonatomic, strong) PasskeyAuthenticator     *passkeyAuthenticator;

@end

extern NSString *const SPAlphabeticalTagSortPref;
extern NSString *const SPSustainerAppIconName;
