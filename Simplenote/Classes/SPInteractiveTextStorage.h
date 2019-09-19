#import <UIKit/UIKit.h>


extern NSString *const SPDefaultTokenName;
extern NSString *const SPHeadlineTokenName;

@interface SPInteractiveTextStorage : NSTextStorage

@property (nonatomic, copy) NSDictionary<NSString *, NSDictionary<NSAttributedStringKey, id> *> *tokens;

@end
