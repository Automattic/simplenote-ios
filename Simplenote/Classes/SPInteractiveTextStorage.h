#import <UIKit/UIKit.h>


extern NSString *const SPDefaultTokenName;
extern NSString *const SPHeadlineTokenName;

@interface SPInteractiveTextStorage : NSTextStorage

@property (nonatomic, copy) NSDictionary *tokens; // a dictionary, keyed by text snippets, with attributes we want to add

@end
