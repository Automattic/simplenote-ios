#import <UIKit/UIKit.h>


@interface SPInteractiveTextStorage : NSTextStorage

@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *defaultStyle;
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *headlineStyle;

@end
