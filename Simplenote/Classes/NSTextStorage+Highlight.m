#import "NSTextStorage+Highlight.h"
#import "NSString+Search.h"

@implementation NSTextStorage (Highlight)

- (void)applyColor:(UIColor *)color toSubstringMatchingKeywords:(NSString *)keywords {
    NSArray* ranges = [self.string rangesForTerms:keywords];
    [self applyColorAttribute:color forRanges:ranges];
}

- (void)applyColorAttribute:(id)color forRanges:(NSArray *)wordRanges {
    
    if (!color) {
        return;
    }
    
    [self beginEditing];

    NSUInteger maxLength = self.string.length;
    
    for (NSValue *rangeValue in wordRanges) {
        
        // Out of Range Failsafe
        NSRange range = rangeValue.rangeValue;
        if (range.location + range.length > maxLength) {
            continue;
        }
        
        // Maintain current Font
        [self addAttribute:NSForegroundColorAttributeName value:color range:rangeValue.rangeValue];
    }
    
    [self endEditing];
}

@end
