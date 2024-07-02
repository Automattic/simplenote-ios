#import <UIKit/UIKit.h>
#import "SPTableViewController.h"
#import "SPModalActivityIndicator.h"

@class PasskeyAuthenticator;

@interface SPSettingsViewController : SPTableViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    //Preferences
    NSNumber *sortOrderPref;
    NSNumber *numPreviewLinesPref;
}

@property (nonatomic, strong, nullable) SPModalActivityIndicator *passkeyActivityIndicator;

@end

extern NSString * _Nonnull const SPAlphabeticalTagSortPref;
extern NSString * _Nonnull const SPSustainerAppIconName;
