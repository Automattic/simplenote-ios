#import "NSTextStorage+Highlight.h"
#import "NSString+Search.h"

@implementation NSTextStorage (Highlight)

- (void)applyColor:(UIColor *)color toSubstringMatchingKeywords:(NSString *)keywords {
    NSArray* ranges = [self.string rangesForTerms:keywords];
    [self applyColor:color toRanges:ranges];
}

- (void)applyColor:(UIColor *)color toRanges:(NSArray *)wordRanges {
    
    if (!color) {
        return;
    }
    
    [self beginEditing];

    NSUInteger maxLength = self.string.length;
    
    for (NSValue *rangeValue in wordRanges) {
        
        // Out of Range Failsafe
        NSRange range = rangeValue.rangeValue;
        if (NSMaxRange(range) > maxLength) {
            continue;
        }
        
        // Maintain current Font
        [self addAttribute:NSForegroundColorAttributeName value:color range:rangeValue.rangeValue];
    }
    
    [self endEditing];
}

@end
