#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableAttributedString (Checklists)
- (void)processChecklistsWithColor:(UIColor *)color allowsMultiplePerLine:(BOOL)allowsMultiplePerLine;
@end

NS_ASSUME_NONNULL_END
