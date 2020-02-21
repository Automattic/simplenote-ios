#import "NSMutableAttributedString+Styling.h"
#import "Simplenote-Swift.h"



@implementation NSMutableAttributedString (Checklists)

- (void)processChecklistsWithColor:(UIColor *)color
{
    CGFloat dimension = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline].pointSize + 4;
    UIOffset offset = UIOffsetMake(0.0, -4.5);

    [self processChecklistsWithColor:color dimension:dimension offset:offset allowsMultiplePerLine:YES];
}

- (void)processChecklistsWithColor:(UIColor *)color
                         dimension:(CGFloat)dimension
                            offset:(UIOffset)offset
             allowsMultiplePerLine:(BOOL)allowsMultiplePerLine
{
    if (self.length == 0) {
        return;
    }

    NSString *plainString = self.string.copy;
    NSRegularExpression *regex = NSRegularExpression.regexForChecklists;
    NSArray *matches = [regex matchesInString:plainString options:0 range:plainString.rangeOfEntireString];

    if (matches.count == 0) {
        return;
    }

    NSInteger positionAdjustment = 0;

    for (NSTextCheckingResult *match in matches) {
        NSRange matchedRange = match.range;
        if (matchedRange.location == NSNotFound) {
            continue;
        }

        NSRange adjustedRange = NSMakeRange(matchedRange.location - positionAdjustment, matchedRange.length);
        if (NSMaxRange(adjustedRange) > self.length) {
            continue;
        }

        NSString *prefix = [plainString substringWithRange:matchedRange];
        BOOL isChecked = [prefix localizedCaseInsensitiveContainsString:@"x"];

        SPTextAttachment *textAttachment = [SPTextAttachment new];
        textAttachment.isChecked = isChecked;
        textAttachment.tintColor = color;
        textAttachment.bounds = CGRectMake(offset.horizontal, offset.vertical, dimension, dimension);

        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [self replaceCharactersInRange:adjustedRange withAttributedString:attachmentString];

        positionAdjustment += matchedRange.length - attachmentString.length;
    }
}

@end
