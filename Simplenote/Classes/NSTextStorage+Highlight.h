#import <UIKit/UIKit.h>

@interface NSTextStorage (Highlight)

- (void)applyColor:(UIColor *)color toSubstringMatchingKeywords:(NSString *)keywords;
- (void)applyColor:(UIColor *)color toRanges:(NSArray *)wordRanges;

@end
