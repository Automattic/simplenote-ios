#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
extern NSString* const NSAttributedStringRegexForChecklists;

@interface NSMutableAttributedString (Checklists)

- (void)processChecklistAttachmentsWithColor:(UIColor *)color;

@end
NS_ASSUME_NONNULL_END
