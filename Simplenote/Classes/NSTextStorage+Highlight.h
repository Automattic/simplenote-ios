#import <UIKit/UIKit.h>

@interface NSTextStorage (Highlight)

- (void)applyColor:(UIColor *)color toSubstringMatchingKeywords:(NSString *)keywords;
- (void)applyColorAttribute:(id)color forRanges:(NSArray *)wordRanges;

@end
